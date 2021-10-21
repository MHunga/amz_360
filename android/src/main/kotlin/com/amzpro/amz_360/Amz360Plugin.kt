package com.amzpro.amz_360

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


/** Amz360Plugin */
class Amz360Plugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var _vibrator: Vibrator

  private  val METHOD_CHANEL_VIBRATE = "amz_vibrate"
  private val METHOD_CHANNEL_SENSOR = "amz_sensors/method"
  private val ORIENTATION_CHANNEL_SENSOR = "amz_sensors/orientation"

  private  lateinit var methodVibrate : MethodChannel

  private var sensorManager: SensorManager? = null
  private var methodSensor: MethodChannel? = null
  private var orientationChannel: EventChannel? = null


  private var orientationStreamHandler: RotationVectorStreamHandler? = null



  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodVibrate = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANEL_VIBRATE)
    methodVibrate.setMethodCallHandler(this)
    _vibrator = flutterPluginBinding.applicationContext.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    setupSensorChannels(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger )
  }




  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when {
        call.method.equals("vibrate") -> {
          //result.success("Android ${android.os.Build.VERSION.RELEASE}")
          if (_vibrator.hasVibrator()){
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
              _vibrator.vibrate( VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE) )
            }else{
                _vibrator.vibrate(50)
            }
          }
          result.success(null)
        }
        call.method.equals("isSensorAvailable") -> {
          result.success(sensorManager!!.getSensorList(call.arguments as Int).isNotEmpty())
        }

        call.method.equals("setSensorUpdateInterval") -> {
          orientationStreamHandler!!.setUpdateInterval(call.argument<Int>("interval")!!)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodVibrate.setMethodCallHandler(null)
    methodSensor!!.setMethodCallHandler(null)
    orientationChannel!!.setStreamHandler(null)
  }


  private fun setupSensorChannels(context: Context, messenger: BinaryMessenger) {
    sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    methodSensor = MethodChannel(messenger, METHOD_CHANNEL_SENSOR)
    methodSensor!!.setMethodCallHandler(this)



    orientationChannel = EventChannel(messenger, ORIENTATION_CHANNEL_SENSOR)
    orientationStreamHandler = RotationVectorStreamHandler(sensorManager!!, Sensor.TYPE_GAME_ROTATION_VECTOR)
    orientationChannel!!.setStreamHandler(orientationStreamHandler!!)

  }

}


class RotationVectorStreamHandler(private val sensorManager: SensorManager, sensorType: Int, private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL) :
        EventChannel.StreamHandler, SensorEventListener {
  private val sensor = sensorManager.getDefaultSensor(sensorType)
  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (sensor != null) {
      eventSink = events
      sensorManager.registerListener(this, sensor, interval)
    }
  }

  override fun onCancel(arguments: Any?) {
    sensorManager.unregisterListener(this)
    eventSink = null
  }

  override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {

  }

  override fun onSensorChanged(event: SensorEvent?) {
    var matrix = FloatArray(9)
    SensorManager.getRotationMatrixFromVector(matrix, event!!.values)
    if (matrix[7] > 1.0f) matrix[7] = 1.0f
    if (matrix[7] < -1.0f) matrix[7] = -1.0f
    var orientation = FloatArray(3)
    SensorManager.getOrientation(matrix, orientation)
    val sensorValues = listOf(-orientation[0], -orientation[1], orientation[2])
    eventSink?.success(sensorValues)
  }

  fun setUpdateInterval(interval: Int) {
    this.interval = interval
    if (eventSink != null) {
      sensorManager.unregisterListener(this)
      sensorManager.registerListener(this, sensor, interval)
    }
  }
}
