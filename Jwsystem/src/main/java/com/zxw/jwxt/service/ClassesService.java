package com.zxw.jwxt.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zxw.common.pojo.RS;
import com.zxw.jwxt.domain.TClasses;
import com.zxw.jwxt.domain.UserRealm;
import com.zxw.jwxt.mapper.TClassesMapper;
import com.zxw.jwxt.vo.QueryClassesVO;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <p>
 * 服务类
 * </p>
 *
 * @author zxw
 * @since 2023-11-07
 */
@Service
//@Transactional(rollbackFor = Exception.class)
public class ClassesService extends BaseService {
    @Autowired
    private TClassesMapper classesMapper;

    private static String qualifySort(String sort, String tableAlias) {
        if (StringUtils.isEmpty(sort)) {
            return sort;
        }
        String[] split = sort.split(",", 2);
        String column = split[0];
        if (column.contains(".") || column.contains("`")) {
            return sort;
        }
        String qualified = tableAlias + ".`" + column + "`";
        return split.length > 1 ? qualified + "," + split[1] : qualified;
    }

    public RS save(TClasses classes) {
        return classesMapper.insert(classes) == 0 ? RS.error("保存失败") : RS.ok("保存成功");
    }

    public IPage pageQuery(QueryClassesVO queryClassesVO, UserRealm realm) {
        queryClassesVO.setSort(qualifySort(queryClassesVO.getSort(), "cs"));
        Page page = getPage(queryClassesVO);
        Map<String, Object> map = new HashMap<>();
        Map<String, Object> keyword = new HashMap<>();
        map.put("cs.`college_id`", realm.getCollegeId());
        map.put("cs.`specialty_id`", queryClassesVO.getSpecialtyId());
        map.put("cs.`grade_id`", queryClassesVO.getGradeId());
        if (StringUtils.isNotEmpty(queryClassesVO.getClassname())) {
            keyword.put("cs.`classname`", queryClassesVO.getClassname());
        }
        return classesMapper.findByParams(page, this.getWrapper(queryClassesVO, keyword, map));
    }

    public RS update(TClasses classes) {
        if (classes == null || StringUtils.isBlank(classes.getId())) {
            return RS.error(400, "缺少班级ID");
        }
        return classesMapper.updateById(classes) == 0 ? RS.error("更新失败") : RS.ok("更新成功");
    }

    public RS deleteById(String id) {
        if (StringUtils.isBlank(id)) {
            return RS.error(400, "缺少班级ID");
        }
        try {
            return classesMapper.deleteById(id) == 0 ? RS.error("删除失败") : RS.ok("删除成功");
        } catch (DataIntegrityViolationException e) {
            return RS.error(400, "该班级下存在学生，无法删除");
        }
    }

    public RS deleteBatch(QueryClassesVO classesVO) {
        if (classesVO == null) {
            return RS.error(400, "缺少参数");
        }
        if (classesVO.getCIds() != null && !classesVO.getCIds().isEmpty()) {
            for (String id : classesVO.getCIds()) {
                RS rs = deleteById(id);
                Object code = rs.get("code");
                if (code instanceof Integer && ((Integer) code) != 0) {
                    return rs;
                }
            }
            return RS.ok("删除成功");
        }
        if (StringUtils.isNotBlank(classesVO.getId())) {
            return deleteById(classesVO.getId());
        }
        return RS.error(400, "请选择要删除的班级");
    }

    public List findClassesByGrade(QueryClassesVO classesVO, UserRealm realm) {
        List list = classesMapper.findClassesByGrade(realm.getCollegeId(),classesVO.getGradeId());
        return list;
    }

    public TClasses findById(String id) {
        TClasses tClasses = classesMapper.selectById(id);
        return tClasses;
    }

    public List findBySpecialty(QueryClassesVO classesVO) {
        QueryWrapper queryWrapper = new QueryWrapper();
        if(StringUtils.isNotEmpty(classesVO.getGradeId())){
            queryWrapper.eq("grade_id", classesVO.getGradeId());
        }
        if(StringUtils.isNotEmpty(classesVO.getSpecialtyId())){
            queryWrapper.eq("specialty_id", classesVO.getSpecialtyId());
        }
        List list = classesMapper.selectList(queryWrapper);
        return list;
    }
}
