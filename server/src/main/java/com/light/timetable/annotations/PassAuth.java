package com.light.timetable.annotations;

import java.lang.annotation.*;

/**
 * 跳过登录校验
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface PassAuth {
}
