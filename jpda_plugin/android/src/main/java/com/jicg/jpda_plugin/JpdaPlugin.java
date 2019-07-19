package com.jicg.jpda_plugin;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import com.jicg.jpda_plugin.activity.MainActivity;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * JpdaPlugin
 */
public class JpdaPlugin implements MethodCallHandler {

    private static final String TAG = "JpdaPlugin";
    private Context ctx;

    private JpdaPlugin(Context context) {
        ctx = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "jpda_plugin");
        JpdaResp.setMethodChannel(channel);
        channel.setMethodCallHandler(new JpdaPlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("openScanEditText")) {
            Intent it = new Intent(ctx, MainActivity.class);
            it.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Object obj = call.arguments;
            String type = "";
            if (obj != null) {
                if (obj instanceof String) {
                    type = (String) obj;
                } else if (obj instanceof Map) {
                    type = "" + ((Map) obj).get("type");
                }
            }
            it.putExtra("type", type);
            ctx.startActivity(it);
            result.success(true);
        } else if ("closeScanEditText".equals(call.method)) {
            if (MainActivity.Instance != null) {
                MainActivity.Instance.finish();
                MainActivity.Instance = null;
            }
            result.success(true);
        } else {

            result.notImplemented();
        }
    }
}
