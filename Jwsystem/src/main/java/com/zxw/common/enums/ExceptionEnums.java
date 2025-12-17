package com.zxw.common.enums;

public enum ExceptionEnums {
    NO_DATA("没有数据");

    private String msg;
    ExceptionEnums(String msg) { this.msg = msg; }
    public String getMsg() { return msg; }
}
