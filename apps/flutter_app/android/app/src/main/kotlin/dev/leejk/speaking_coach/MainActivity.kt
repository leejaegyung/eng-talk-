package dev.leejk.speaking_coach

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "speaking_coach/update")
            .setMethodCallHandler { call, result ->
                if (call.method != "installApk") return@setMethodCallHandler result.notImplemented()
                val path = call.argument<String>("path")
                val updates = File(cacheDir, "updates").canonicalFile
                val apk = path?.let { File(it).canonicalFile }
                // Only APKs the app itself downloaded into its cache.
                if (apk == null || apk.parentFile != updates || !apk.isFile) {
                    return@setMethodCallHandler result.error("bad_path", null, null)
                }
                try {
                    val uri = FileProvider.getUriForFile(this, "$packageName.updates", apk)
                    // The system installer asks the user to confirm (and, the
                    // first time, to allow installs from this app).
                    startActivity(
                        Intent(Intent.ACTION_VIEW)
                            .setDataAndType(uri, "application/vnd.android.package-archive")
                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("install_failed", e.javaClass.simpleName, null)
                }
            }
    }
}
