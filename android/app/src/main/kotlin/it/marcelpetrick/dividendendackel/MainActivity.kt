package it.marcelpetrick.dividendendackel

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingCalendarResult: MethodChannel.Result? = null
    private var pendingCalendarBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CALENDAR_EXPORT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "createDocument") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingCalendarResult != null) {
                result.error(
                    "export_in_progress",
                    "Another calendar export is already in progress.",
                    null,
                )
                return@setMethodCallHandler
            }
            val name = call.argument<String>("name")
            val mimeType = call.argument<String>("mimeType")
            val bytes = call.argument<ByteArray>("bytes")
            if (name.isNullOrBlank() || mimeType.isNullOrBlank() || bytes == null) {
                result.error("invalid_export", "Calendar export data is incomplete.", null)
                return@setMethodCallHandler
            }

            pendingCalendarResult = result
            pendingCalendarBytes = bytes
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = mimeType
                putExtra(Intent.EXTRA_TITLE, name)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }
            try {
                startActivityForResult(intent, CALENDAR_EXPORT_REQUEST)
            } catch (error: Exception) {
                clearPendingCalendarExport()
                result.error(
                    "export_unavailable",
                    "No document provider is available.",
                    error.message,
                )
            }
        }
    }

    @Deprecated("Deprecated in Android; retained for API 29 document creation.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CALENDAR_EXPORT_REQUEST) return

        val result = pendingCalendarResult ?: return
        val bytes = pendingCalendarBytes
        clearPendingCalendarExport()
        val destination = data?.data
        if (resultCode != Activity.RESULT_OK || destination == null || bytes == null) {
            result.success(false)
            return
        }
        try {
            val stream = contentResolver.openOutputStream(destination, "w")
                ?: throw IllegalStateException("The selected document cannot be opened.")
            stream.use { output ->
                output.write(bytes)
                output.flush()
            }
            result.success(true)
        } catch (error: Exception) {
            result.error(
                "export_failed",
                "The selected document could not be written.",
                error.message,
            )
        }
    }

    private fun clearPendingCalendarExport() {
        pendingCalendarResult = null
        pendingCalendarBytes = null
    }

    companion object {
        private const val CALENDAR_EXPORT_CHANNEL =
            "it.marcelpetrick.dividendendackel/calendar_export"
        private const val CALENDAR_EXPORT_REQUEST = 8142
    }
}
