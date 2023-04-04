package com.example.flutter_fan_module

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.adsmanager.core.CallbackAds
import com.adsmanager.core.iadsmanager.IInitialize
import com.adsmanager.core.rewards.IRewards
import com.adsmanager.core.rewards.RewardsItem
import com.adsmanager.fan.FanAds
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterFanModulePlugin */
class FlutterFanModulePlugin() : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val CALLBACK_CHANNEL = "flutter_fan_module_callback"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var fanAds: FanAds
    private lateinit var context: Context
    private lateinit var callbackChannel: BasicMessageChannel<String>
    private lateinit var activity: Activity
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_fan_module")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initialize" -> {
                val appId = call.argument<String>("appId") ?: ""
                fanAds.initialize(context, appId, object : IInitialize {
                    override fun onInitializationComplete() {
                        activity.runOnUiThread {
                            callbackChannel.send("onInitializationComplete|")
                        }
                    }
                })
                flutterPluginBinding.platformViewRegistry.registerViewFactory(
                    "bannerFan",
                    BannerPlatformViewFactory(
                        StandardMessageCodec.INSTANCE,
                        activity,
                        context,
                        fanAds,
                        callbackChannel
                    )
                )
                flutterPluginBinding.platformViewRegistry.registerViewFactory(
                    "nativeFan",
                    NativePlatformViewFactory(
                        StandardMessageCodec.INSTANCE,
                        activity,
                        context,
                        fanAds,
                        callbackChannel
                    )
                )
            }
            "setTestDevices" -> {
                val testDevices = call.argument<List<String>>("testDevices")
                testDevices?.let { fanAds.setTestDevices(activity, it) }
            }
            "loadGdpr" -> {
                val childDirected = call.argument<Boolean>("childDirected")
                fanAds.loadGdpr(activity, childDirected == true)
            }
            "loadInterstitial" -> {
                val adUnitId = call.argument<String>("adUnitId")
                adUnitId?.let { fanAds.loadInterstitial(activity, it) }
            }
            "loadRewards" -> {
                val adUnitId = call.argument<String>("adUnitId")
                adUnitId?.let { fanAds.loadRewards(activity, it) }
            }
            "showInterstitial" -> {
                val adUnitId = call.argument<String>("adUnitId")
                adUnitId?.let {
                    fanAds.showInterstitial(activity, it, object : CallbackAds() {
                        override fun onAdFailedToLoad(error: String?) {
                            super.onAdFailedToLoad(error)
                            activity.runOnUiThread {
                                callbackChannel.send("InterstitialAdFailedToLoad|$error")
                            }
                        }

                        override fun onAdLoaded() {
                            super.onAdLoaded()
                            activity.runOnUiThread {
                                callbackChannel.send("InterstitialAdLoaded|")
                            }
                        }
                    })
                }
            }
            "showRewards" -> {
                val adUnitId = call.argument<String>("adUnitId")
                adUnitId?.let {
                    fanAds.showRewards(activity, it, object : CallbackAds() {
                        override fun onAdFailedToLoad(error: String?) {
                            super.onAdFailedToLoad(error)
                            activity.runOnUiThread {
                                callbackChannel.send("RewardsAdFailedToLoad|$error")
                            }
                        }

                        override fun onAdLoaded() {
                            super.onAdLoaded()
                            activity.runOnUiThread {
                                callbackChannel.send("RewardsAdLoaded|")
                            }
                        }
                    }, object : IRewards {
                        override fun onUserEarnedReward(rewardsItem: RewardsItem?) {
                            activity.runOnUiThread {
                                callbackChannel.send("RewardsUserEarnedReward|${rewardsItem.toString()}")
                            }
                        }
                    })
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        fanAds = FanAds()
        activity = binding.activity
        channel.setMethodCallHandler(this)
        context = binding.activity
        callbackChannel =
            BasicMessageChannel(binaryMessenger, CALLBACK_CHANNEL, StringCodec.INSTANCE)
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {

    }
}
