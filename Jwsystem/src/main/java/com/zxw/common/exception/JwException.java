package com.zxw.common.exception;
import com.zxw.common.enums.ExceptionEnums;

public class JwException extends RuntimeException {
    private ExceptionEnums exceptionEnums;
    public JwException(ExceptionEnums exceptionEnums) {
        super(exceptionEnums.getMsg());
        this.exceptionEnums = exceptionEnums;
    }
}
