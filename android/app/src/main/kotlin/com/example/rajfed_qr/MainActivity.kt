package com.rajfed.qr

import android.Manifest
import android.annotation.SuppressLint
import android.location.Location
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rajfed.qr/location"
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLocation") {
                getLastKnownLocation(result)
            } else {
                result.notImplemented()
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun getLastKnownLocation(result: MethodChannel.Result) {
        // Assumes you already have location permission
        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    val locationMap = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude
                    )
                    result.success(locationMap)
                } else {
                    result.error("NO_LOCATION", "Location is null", null)
                }
            }
            .addOnFailureListener {
                result.error("FAILED", "Failed to get location", it.message)
            }
    }
}
