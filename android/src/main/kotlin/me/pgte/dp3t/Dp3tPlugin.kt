package me.pgte.dp3t

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.collections.HashMap
import kotlin.collections.ArrayList
import java.util.Date

import org.dpppt.android.sdk.DP3T
import org.dpppt.android.sdk.TracingStatus
import org.dpppt.android.sdk.InfectionStatus
import org.dpppt.android.sdk.backend.ResponseCallback
import org.dpppt.android.sdk.internal.database.Database
import org.dpppt.android.sdk.backend.models.ApplicationInfo
import org.dpppt.android.sdk.backend.models.ExposeeAuthMethodAuthorization

/** Dp3tPlugin */
public class Dp3tPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel;
  private lateinit var applicationContext : Context;

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding);
  }

  fun onAttachedToEngine(applicationContext: Context, flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.applicationContext = applicationContext;
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "dp3t")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "dp3t")
      channel.setMethodCallHandler(Dp3tPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val uiThreadHandler = Handler(Looper.getMainLooper())
    var notImplemented = false
    val respond: (Throwable?, Any?) -> Unit = { t, v ->
      uiThreadHandler.post {
        if (t != null) {
          result.error("error", t.message, null)
        } else {
          result.success(v)
        }
      }
    }

    when(call.method) {
      "initializeManually" -> uiThreadHandler.post {
        _initializeManually(call, respond)
      }
      "initializeWithDiscovery" -> uiThreadHandler.post {
        _initializeWithDiscovery(call, respond)
      }
      "reset" -> uiThreadHandler.post {
        _reset(respond)
      }
      "startTracing" -> uiThreadHandler.post {
        _startTracing(respond)
      }
      "stopTracing" -> uiThreadHandler.post {
        _stopTracing(respond)
      }
      "status" -> uiThreadHandler.post {
        _status(respond)
      }
      "iWasExposed" -> uiThreadHandler.post {
        _iWasExposed(call, respond)
      }
      else -> notImplemented = true
    }
    if (notImplemented) {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  fun _reset(callback: (Throwable?, Any?) -> (Any?)) {
    try {
      DP3T.clearData(this.applicationContext) { callback(null, null) }
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _startTracing(callback: (Throwable?, Any?) -> (Any?)) {
    try {
      DP3T.start(this.applicationContext)
      callback(null, null)
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _stopTracing(callback: (Throwable?, Any?) -> (Any?)) {
    try {
      DP3T.stop(this.applicationContext)
      callback(null, null);
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _status(callback: (Throwable?, Any?) -> (Any?)) {
    try {
      val status = DP3T.getStatus(this.applicationContext)
      callback(null, _formatStatus(this.applicationContext, status))
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _iWasExposed(call: MethodCall, callback: (Throwable?, Any?) -> (Any?)) {
    try {
      val args = call.arguments as Map<String, String>
      val timestampLong = args.get("onset")!!.toLong(10)
      val date = Date(timestampLong * 1000) // arguments comes in seconds, and Date expects miliseconds

      DP3T.sendIAmInfected(this.applicationContext, date, ExposeeAuthMethodAuthorization(args.get("authentication")), object : ResponseCallback<Void?> {
        override fun onSuccess(response: Void?) {
          callback(null, null)
        }

        override fun onError(throwable: Throwable) {
          callback(throwable, null)
        }
      })
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _initializeManually(call: MethodCall, callback: (Throwable?, Any?) -> (Any?)) {
    try {
      val args = call.arguments as Map<String, String>
      val appId = args.get("appId")
      val bucketBaseUrl = args.get("bucketBaseUrl")
      val reportBaseUrl = args.get("reportBaseUrl")

      DP3T.init(
        this.applicationContext,
        ApplicationInfo(appId, bucketBaseUrl, reportBaseUrl))

      callback(null, null)
    } catch (throwable: Throwable) {
      callback(throwable, null)
    }
  }

  fun _initializeWithDiscovery(call: MethodCall, callback: (Throwable?, Any?) -> (Any?)) {
    try {
      val args = call.arguments as Map<String, String>
      val appId = args.get("appId")
      val environment = args.get("environment")
      val dev = environment == "dev"

      DP3T.init(this.applicationContext, appId, dev)
      callback(null, null)
    } catch(throwable: Throwable) {
      callback(throwable, null)
    }
  }


  // public fun checkBatteryOptimizationDeactivated(promise: Promise) {
  //   try {
  //     val powerManager = reactApplicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
  //     val batteryOptimizationDeactivated = powerManager.isIgnoringBatteryOptimizations(reactApplicationContext.packageName)

  //     if (!batteryOptimizationDeactivated) {
  //       val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
  //         Uri.parse("package:" + reactApplicationContext.packageName))
  //       intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
  //       reactApplicationContext.startActivity(intent)
  //     }
  //     promise.resolve(null)
  //   } catch (throwable: Throwable) {
  //     promise.reject(throwable)
  //   }
  // }

  // private fun registerUpdateIntentReceiver() {
  //   if (!updateIntentReceiverRegistered) {
  //     reactApplicationContext.registerReceiver(object : BroadcastReceiver() {
  //       override fun onReceive(context: Context, intent: Intent) {
  //         reactApplicationContext
  //           .getJSModule(RCTDeviceEventEmitter::class.java)
  //           .emit("Dp3tStatusUpdated", toJSStatus(reactApplicationContext.applicationContext, DP3T.getStatus(reactApplicationContext.applicationContext)))
  //       }
  //     }, DP3T.getUpdateIntentFilter())
  //     updateIntentReceiverRegistered = true
  //   }
  // }

  // fun stop(promise: Promise) {
  //   try {
  //     DP3T.stop(reactApplicationContext.applicationContext)
  //     promise.resolve(null);
  //   } catch (throwable: Throwable) {
  //     promise.reject(throwable);
  //   }
  // }

  // fun currentTracingStatus(promise: Promise) {
  //   try {
  //     val status = DP3T.getStatus(reactApplicationContext.applicationContext)

  //     promise.resolve(toJSStatus(reactApplicationContext.applicationContext, status))
  //   } catch (throwable: Throwable) {
  //     promise.reject(throwable)
  //   }
  // }

  // fun sendIAmInfected(timestamp: String, authString: String, promise: Promise) {
  //   try {
  //     val timestampLong = timestamp.toLong(10);
  //     val date = Date(timestampLong)

  //     DP3T.sendIAmInfected(reactApplicationContext, date, ExposeeAuthMethodAuthorization(authString), object : ResponseCallback<Void?> {
  //       override fun onSuccess(response: Void?) {
  //         promise.resolve(null)
  //       }

  //       override fun onError(throwable: Throwable) {
  //         promise.reject(throwable)
  //       }
  //     })
  //   } catch (throwable: Throwable) {
  //     promise.reject(throwable);
  //   }
  // }

  // fun sync(promise: Promise) {
  //   if (syncThread != null) {
  //     return promise.resolve(false);
  //   }
  //   syncThread = thread {
  //     try {
  //       DP3T.sync(reactApplicationContext);
  //       promise.resolve(true)
  //     } catch (throwable: Throwable) {
  //       promise.reject(throwable);
  //     } finally {
  //       syncThread = null
  //     }
  //   }
  // }

  private fun _formatStatus(context: Context, status: TracingStatus): HashMap<String, Any?> {
    val map = HashMap<String, Any?>()
    val database = Database(context)

    val tracingState = if (status.errors.isNotEmpty()) "error" else if (status.isReceiving) "started" else "stopped"
    val healthStatus = if (status.infectionStatus == InfectionStatus.EXPOSED) "exposed" else if (status.infectionStatus == InfectionStatus.INFECTED) "infected" else "healthy"

    map.put("tracingState", tracingState)
    map.put("numberOfHandshakes", database.handshakes.size)
    map.put("numberOfContacts", status.numberOfContacts)
    map.put("healthStatus", healthStatus)

    if (status.lastSyncDate > 0) {
      map.put("lastSyncDate", status.lastSyncDate.toString(10))
    }

    val errors = ArrayList<String>()
    val nativeErrors = ArrayList<String>()
    status.errors.forEach {
      nativeErrors.add(it.name)
      when (it) {
        TracingStatus.ErrorState.BLE_DISABLED -> errors.add("bluetoothDisabled")
        TracingStatus.ErrorState.MISSING_LOCATION_PERMISSION, TracingStatus.ErrorState.BATTERY_OPTIMIZER_ENABLED -> errors.add("permissionMissing")
        TracingStatus.ErrorState.SYNC_ERROR_SERVER, TracingStatus.ErrorState.SYNC_ERROR_NETWORK, TracingStatus.ErrorState.SYNC_ERROR_TIMING, TracingStatus.ErrorState.SYNC_ERROR_DATABASE, TracingStatus.ErrorState.SYNC_ERROR_SIGNATURE -> errors.add("sync")
        else -> errors.add("other")
      }
    }
    map.put("errors", errors)
    map.put("nativeErrors", nativeErrors)

    val matchedContacts = ArrayList<HashMap<String, String>>()
    database.allMatchedContacts.forEach() {
      val contact = HashMap<String, String>()
      contact.put("id", it.id.toString())
      contact.put("reportDate", it.date.toString(10))
      matchedContacts.add(contact)
    }

    map.put("matchedContacts", matchedContacts)

    return map
  }
}
