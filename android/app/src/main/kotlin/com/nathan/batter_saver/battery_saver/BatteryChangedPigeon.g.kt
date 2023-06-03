// Autogenerated from Pigeon (v10.0.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon


import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  if (exception is FlutterError) {
    return listOf(
      exception.code,
      exception.message,
      exception.details
    )
  } else {
    return listOf(
      exception.javaClass.simpleName,
      exception.toString(),
      "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
    )
  }
}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeBatteryInfo (
  val batteryLevel: Long? = null,
  val batteryTemperature: Long? = null,
  val voltage: Long? = null,
  val currentNow: Long? = null,
  val avgCurrent: Long? = null,
  val batteryLow: Boolean? = null,
  val batteryPresent: Boolean? = null,
  val batteryStatus: String? = null,
  val chargePlug: String? = null,
  val batteryHealth: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeBatteryInfo {
      val batteryLevel = list[0].let { if (it is Int) it.toLong() else it as Long? }
      val batteryTemperature = list[1].let { if (it is Int) it.toLong() else it as Long? }
      val voltage = list[2].let { if (it is Int) it.toLong() else it as Long? }
      val currentNow = list[3].let { if (it is Int) it.toLong() else it as Long? }
      val avgCurrent = list[4].let { if (it is Int) it.toLong() else it as Long? }
      val batteryLow = list[5] as Boolean?
      val batteryPresent = list[6] as Boolean?
      val batteryStatus = list[7] as String?
      val chargePlug = list[8] as String?
      val batteryHealth = list[9] as String?
      return NativeBatteryInfo(batteryLevel, batteryTemperature, voltage, currentNow, avgCurrent, batteryLow, batteryPresent, batteryStatus, chargePlug, batteryHealth)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      batteryLevel,
      batteryTemperature,
      voltage,
      currentNow,
      avgCurrent,
      batteryLow,
      batteryPresent,
      batteryStatus,
      chargePlug,
      batteryHealth,
    )
  }
}
@Suppress("UNCHECKED_CAST")
private object BatteryChangedPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeBatteryInfo.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is NativeBatteryInfo -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
@Suppress("UNCHECKED_CAST")
class BatteryChangedPigeon(private val binaryMessenger: BinaryMessenger) {
  companion object {
    /** The codec used by BatteryChangedPigeon. */
    val codec: MessageCodec<Any?> by lazy {
      BatteryChangedPigeonCodec
    }
  }
  fun nativeSendMessage(infoArg: NativeBatteryInfo, callback: () -> Unit) {
    val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.BatteryChangedPigeon.nativeSendMessage", codec)
    channel.send(listOf(infoArg)) {
      callback()
    }
  }
}
