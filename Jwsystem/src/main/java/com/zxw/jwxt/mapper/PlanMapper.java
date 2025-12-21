package com.zxw.jwxt.mapper;

import com.zxw.jwxt.domain.Plan;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.zxw.jwxt.dto.PlanDTO;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author zxw
 * @since 2020-01-05
 */
public interface PlanMapper extends BaseMapper<Plan> {

    @Select("SELECT p.id, p.name, p.year_id AS yearId, sp.`name` AS sname " +
            "FROM `plan` p " +
            "LEFT JOIN `t_specialty` sp ON p.`specialty_id` = sp.`id` " +
            "WHERE (#{specialtyId} IS NULL OR #{specialtyId} = '' OR p.`specialty_id` = #{specialtyId})")
    List<PlanDTO> listajax(@Param("specialtyId") String specialtyId);
}
