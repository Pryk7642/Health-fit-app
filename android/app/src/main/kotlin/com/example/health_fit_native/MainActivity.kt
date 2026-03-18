package com.example.health_fit_native

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.*
import com.google.android.gms.fitness.*
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {

    private val CHANNEL = "google_fit"
    private val LOGIN = 1001

    private lateinit var client: GoogleSignInClient
    private var loginResult: MethodChannel.Result? = null
    private lateinit var account: GoogleSignInAccount

    private val fitnessOptions: FitnessOptions by lazy {
        FitnessOptions.builder()
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_HEART_RATE_BPM, FitnessOptions.ACCESS_READ)
            .build()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> login(result)
                    "logout" -> logout(result)
                    "getSteps" -> {
                        val start = call.argument<Long>("start")!!
                        val end = call.argument<Long>("end")!!
                        readSteps(start, end, result)
                    }
                    "getHeartRate" -> readHeartRate(result)
                    "tryReconnect" -> {
                        tryReconnect(result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ---------------- LOGIN ----------------
    private fun login(result: MethodChannel.Result) {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .addExtension(fitnessOptions)
            .requestEmail()
            .build()

        client = GoogleSignIn.getClient(this, gso)
        loginResult = result
        startActivityForResult(client.signInIntent, LOGIN)
    }

    private fun tryReconnect(result: MethodChannel.Result) {
        val acc = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
        if (acc != null) {
            account = acc
            result.success(true)
        } else {
            result.success(false)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // if (code == LOGIN && res == Activity.RESULT_OK) {
        //     account = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
        //     val email = account.email
        //     loginResult?.success(email)
        // } else {
        //     loginResult?.success(null)
        // }

        if (requestCode == LOGIN && resultCode == Activity.RESULT_OK) {
            account = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
            loginResult?.success(account.email) // ✅ ส่ง email กลับ Flutter
        } else {
            loginResult?.success(null)
        }
    }

    // ---------------- LOGOUT ----------------
    private fun logout(result: MethodChannel.Result) {
        if (!::client.isInitialized) {
            result.success(true)
            return
        }

        client.signOut().addOnCompleteListener {
            client.revokeAccess().addOnCompleteListener {
                result.success(true)
            }
        }
    }

    // ---------------- STEPS ----------------
    private fun readSteps(start: Long, end: Long, result: MethodChannel.Result) {
        val request = DataReadRequest.Builder()
            .aggregate(
                DataType.TYPE_STEP_COUNT_DELTA,
                DataType.AGGREGATE_STEP_COUNT_DELTA
            )
            .bucketByTime(1, TimeUnit.DAYS)
            .setTimeRange(start, end, TimeUnit.MILLISECONDS)
            .build()

        Fitness.getHistoryClient(this, account)
            .readData(request)
            .addOnSuccessListener { response ->
                var steps = 0
                response.buckets.forEach { bucket ->
                    bucket.dataSets.forEach { set ->
                        set.dataPoints.forEach { point ->
                            steps += point.getValue(Field.FIELD_STEPS).asInt()
                        }
                    }
                }
                result.success(steps)
            }
            .addOnFailureListener {
                result.error("STEP_ERROR", it.message, null)
            }
    }

    // ---------------- HEART RATE ----------------
    private fun readHeartRate(result: MethodChannel.Result) {
        val end = System.currentTimeMillis()
        val start = end - TimeUnit.HOURS.toMillis(24)

        val request = DataReadRequest.Builder()
            .read(DataType.TYPE_HEART_RATE_BPM)
            .setTimeRange(start, end, TimeUnit.MILLISECONDS)
            .build()

        Fitness.getHistoryClient(this, account)
            .readData(request)
            .addOnSuccessListener { response ->
                var latestHR = 0f
                var latestTime = 0L

                response.dataSets.forEach { set ->
                    set.dataPoints.forEach { point ->
                        val t = point.getEndTime(TimeUnit.MILLISECONDS)
                        if (t > latestTime) {
                            latestTime = t
                            latestHR = point.getValue(Field.FIELD_BPM).asFloat()
                        }
                    }
                }
                result.success(latestHR)
            }
            .addOnFailureListener {
                result.error("HR_ERROR", it.message, null)
            }
    }
}
