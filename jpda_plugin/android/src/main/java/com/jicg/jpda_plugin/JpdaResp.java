package com.jicg.jpda_plugin;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class JpdaResp {
    public static void setMethodChannel(MethodChannel channel) {
        JpdaResp.channel = channel;
    }

    private static MethodChannel channel;


    public static void scanRestult(String type, String no, MethodChannel.Result callback) {
        if (channel == null) return;
        Map<String, String> ret = new HashMap<>();
        ret.put("no", no);
        ret.put("type", type);
        channel.invokeMethod("scanRestult", ret, callback);
    }
}
