package com.jicg.jpda_plugin.activity;


import android.app.Activity;
import android.os.Bundle;
import android.text.method.ReplacementTransformationMethod;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.jicg.jpda_plugin.JpdaResp;
import com.jicg.jpda_plugin.R;

import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends Activity {

    public static MainActivity Instance;

    private static final String TAG = "JpdaPlugin";
    EditText edit_scan;
    LinearLayout bg_layout;
    private String type = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Instance = this;
        setContentView(R.layout.activity_main);

        this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        bg_layout = findViewById(R.id.bg_layout);
        edit_scan = findViewById(R.id.edit_scan);
        edit_scan.requestFocus();
        edit_scan.setTransformationMethod(new InputLowerToUpper());

        bg_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MainActivity.this.finish();
            }
        });
        edit_scan.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if ((event != null && event.getAction() != KeyEvent.ACTION_DOWN)) {
                    return true;
                }
                String text = edit_scan.getText().toString();
                Log.i(TAG, "onEditorAction: " + text);
                if (text.trim().equals("")) {
                    return true;
                }
                setMsg(text.toUpperCase());
                edit_scan.setText("");
                return true;
            }
        });
    }


    public void setMsg(String text) {
        JpdaResp.scanRestult(type, text, new MethodChannel.Result() {
            @Override
            public void success(Object o) {

            }

            @Override
            public void error(String s, String s1, Object o) {

            }

            @Override
            public void notImplemented() {

            }
        });
    }

}

class InputLowerToUpper extends ReplacementTransformationMethod {
    @Override
    protected char[] getOriginal() {
        char[] lower = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
        return lower;
    }

    @Override
    protected char[] getReplacement() {
        char[] upper = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
        return upper;
    }

}
