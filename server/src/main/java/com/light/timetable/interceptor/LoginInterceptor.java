package com.light.timetable.interceptor;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.light.timetable.annotations.PassAuth;
import com.light.timetable.model.ResponseWrap;
import com.light.timetable.properties.JwtProperties;
import com.light.timetable.share.SessionKey;
import com.light.timetable.utils.TextUtils;
import org.jetbrains.annotations.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

public class LoginInterceptor implements HandlerInterceptor {

    private final Logger logger = LoggerFactory.getLogger(getClass());


    private JWTVerifier jwtVerifier;

    @Autowired
    public void setJwtVerifier(JwtProperties jwtProperties) {
        this.jwtVerifier = JWT.require(Algorithm.HMAC256(jwtProperties.getKey())).build();
        ;
    }

    @Override
    public boolean preHandle(@NotNull HttpServletRequest request, @NotNull HttpServletResponse response, @NotNull Object handler) throws Exception {
        if (request.getMethod().equalsIgnoreCase("OPTIONS")) {
            return true;
        }

        if (isPassAuth(handler)) {
            return true;
        }
        String token = request.getHeader("token");
        if (TextUtils.isEmpty(token) && request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if (cookie.getName().equals("token")) {
                    token = cookie.getValue();
                }
            }
        }
        if (TextUtils.isEmpty(token)) {
            response.sendError(401, ResponseWrap.error("请先登录!!!").toJson());
            return false;
        }

        try {
            // 验证 token
            List<String> list = jwtVerifier.verify(token).getAudience();
            final String id = list != null && list.size() > 0 ? list.get(0) : "";

            if (TextUtils.isEmpty(id)) {
                return false;
            } else {
                request.setAttribute(SessionKey.USER, Integer.parseInt(id));
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            response.sendError(401, ResponseWrap.error("请先登录!!!").toJson());
            return false;
        }
        return true;
    }

    @Override
    public void postHandle(@NotNull HttpServletRequest request, @NotNull HttpServletResponse response, @NotNull Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(@NotNull HttpServletRequest request, @NotNull HttpServletResponse response, @NotNull Object handler, Exception ex) throws Exception {

    }

    private boolean isPassAuth(Object handler) {
        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            return handlerMethod.getMethod().getAnnotation(PassAuth.class) != null;
        }
        return false;

    }
}
