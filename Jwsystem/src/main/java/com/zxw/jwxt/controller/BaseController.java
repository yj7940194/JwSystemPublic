package com.zxw.jwxt.controller;

import com.zxw.jwxt.domain.UserRealm;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authz.UnauthenticatedException;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.Subject;

/**
 * @author zxw
 * @date 2019/11/7 21:12
 */
public class BaseController {

    public String getUserId() {
        return getRealm().getId();
    }

    public String getUserQx() {
        String qx = (String) SecurityUtils.getSubject().getSession().getAttribute("qx");
        return qx;
    }

    public UserRealm getRealm() {
        Subject subject = SecurityUtils.getSubject();
        Object principal = subject.getPrincipal();
        if (principal instanceof UserRealm) {
            return (UserRealm) principal;
        }
        throw new UnauthenticatedException("未登录或会话已过期");
    }

    public String loginType(){
        String RadioButtonList1 = (String) SecurityUtils.getSubject().getSession().getAttribute("RadioButtonList1");
        return RadioButtonList1;
    }

    public Session getSubjectSeesion(){
        return SecurityUtils.getSubject().getSession();
    }
}
