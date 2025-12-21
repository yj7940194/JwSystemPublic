package com.zxw.common.pojo;

import java.util.HashMap;

public class RS extends HashMap<String, Object> {
    private static final long serialVersionUID = 1L;

    public RS() {
        put("code", 0);
        put("msg", "success");
        put("status", "1");
    }

    public static RS error() {
        return error(500, "未知异常，请联系管理员");
    }

    public static RS error(String msg) {
        return error(500, msg);
    }

    public static RS error(int code, String msg) {
        RS r = new RS();
        r.put("status", "0");
        r.put("code", code);
        r.put("msg", msg);
        return r;
    }

    public static RS ok(String msg) {
        RS r = new RS();
        r.put("msg", msg);
        return r;
    }

    public static RS ok(Object map) {
        RS r = new RS();
        r.put("data", map);
        return r;
    }

    public static RS ok() {
        return new RS();
    }

    @Override
    public RS put(String key, Object value) {
        super.put(key, value);
        return this;
    }
}
