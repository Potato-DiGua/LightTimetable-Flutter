package com.light.timetable.mapper;

import com.light.timetable.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.jetbrains.annotations.Nullable;

@Mapper
public interface UserMapper {

    User getUser(@Param("account") String account);

    int registerUser(User user);

    User getUserById(@Param("id") int id);

    int updateIconById(@Param("id") int id, @Param("icon") String icon);

    @Nullable
    String getIconById(@Param("id") int id);
}
