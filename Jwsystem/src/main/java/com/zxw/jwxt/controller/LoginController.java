package com.zxw.jwxt.controller;

import com.zxw.common.enums.ExceptionEnums;
import com.zxw.common.exception.BadRequestException;
import com.zxw.common.exception.JwException;
import com.zxw.common.pojo.RS;
import com.zxw.jwxt.domain.UserRealm;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.subject.Subject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.UUID;

/**
 * @author zxw
 * @date 2019/11/8 21:24
 */
@RestController
@RequestMapping("/api")
public class LoginController extends BaseController {

    /**
     * CI/自动化场景可通过环境变量开启跳过验证码校验：
     *   JW_CAPTCHA_BYPASS=true
     * 默认为 false，生产/日常使用保持验证码生效。
     */
    @Value("${jw.captcha.bypass:false}")
    private boolean captchaBypass;

    /**
     * 登录功能
     *
     * @param username         用户名
     * @param password         密码
     * @param checkcode        验证码
     * @param RadioButtonList1 身份
     * @param request
     * @return
     */
    @PostMapping("/login")
    @ResponseBody
    public ResponseEntity login(String username, String password, String checkcode, String RadioButtonList1, HttpServletRequest request) {
        if (checkcode == null || checkcode.trim().isEmpty()) {
            throw new BadRequestException("验证码不能为空");
        }

        if (!captchaBypass) {
            HttpSession session = request.getSession();
            String sessionKey = "code_" + session.getId();
            Object expected = session.getAttribute(sessionKey);
            if (expected == null || !checkcode.trim().equalsIgnoreCase(String.valueOf(expected))) {
                throw new BadRequestException("验证码错误");
            }
            // 一次性验证码，验证成功后清理
            session.removeAttribute(sessionKey);
        }

        Subject subject = SecurityUtils.getSubject();
        AuthenticationToken token = new UsernamePasswordToken(username, password);
        try {
            subject.getSession().setAttribute("RadioButtonList1", RadioButtonList1);
            subject.login(token);
        } catch (AuthenticationException e) {
            throw new BadRequestException("用户名或密码错误");
        }
        getRealm().setToken(UUID.randomUUID().toString());
        return ResponseEntity.ok(getRealm());
    }

    /**
     * 用户退出时，销毁Session
     *
     * @return
     */
    @DeleteMapping("/logout")
    public RS logout() {
        Subject subject = SecurityUtils.getSubject();
        subject.logout();
        return RS.ok();
    }

    /**
     * 获取用户信息
     *
     * @return
     */
    @GetMapping("/info")
    public ResponseEntity info() {
        UserRealm realm = getRealm();
        return ResponseEntity.ok(realm);
    }

}
