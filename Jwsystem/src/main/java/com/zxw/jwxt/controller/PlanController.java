package com.zxw.jwxt.controller;


import com.zxw.common.exception.BadRequestException;
import com.zxw.common.pojo.RS;
import com.zxw.jwxt.domain.Plan;
import com.zxw.jwxt.domain.TClasses;
import com.zxw.jwxt.domain.TStudent;
import com.zxw.jwxt.dto.PlanDTO;
import com.zxw.jwxt.service.ClassesService;
import com.zxw.jwxt.service.PlanService;
import com.zxw.jwxt.vo.QueryPlanVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author zxw
 * @since 2020-01-05
 */
@RestController
@RequestMapping("/api/plan")
public class PlanController extends BaseController {
    @Autowired
    private PlanService planService;
    @Autowired
    private ClassesService classesService;

    @GetMapping("/listajax")
    public ResponseEntity listajax(QueryPlanVO planVO) {
        if ((planVO.getSpecialtyId() == null || planVO.getSpecialtyId().trim().isEmpty())
                && getRealm() != null
                && "学生".equals(getRealm().getQx())) {
            TStudent student = (TStudent) getRealm();
            if (student.getClassesId() != null && !student.getClassesId().trim().isEmpty()) {
                TClasses classes = classesService.findById(student.getClassesId());
                if (classes != null && classes.getSpecialtyId() != null) {
                    planVO.setSpecialtyId(classes.getSpecialtyId());
                }
            }
        }
        List<PlanDTO> list = planService.listajax(planVO);
        return ResponseEntity.ok(list);
    }

    @PostMapping
    public ResponseEntity add(@RequestBody Plan plan) {
        RS rs = planService.add(plan);
        if (rs.get("status").equals("1")) {
            return ResponseEntity.ok(rs);
        }
        throw new BadRequestException("添加失败");
    }

    @PutMapping
    public ResponseEntity edit(@RequestBody Plan plan) {
        RS rs = planService.edit(plan);
        if (rs.get("status").equals("1")) {
            return ResponseEntity.ok(rs);
        }
        throw new BadRequestException("修改失败");
    }

    @DeleteMapping
    public ResponseEntity delete(@RequestParam("id") String id) {
        RS rs = planService.delete(id);
        if (rs.get("status").equals("1")) {
            return ResponseEntity.ok(rs);
        }
        throw new BadRequestException("删除失败");
    }
}
