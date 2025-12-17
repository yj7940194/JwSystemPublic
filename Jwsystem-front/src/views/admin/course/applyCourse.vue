<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <el-input v-model="query.cname" clearable size="small" placeholder="输入课程名称搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表单组件-->
    <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="600px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="80px">
        <el-form-item label="课程" prop="cid">
            <el-select v-model="form.cid" placeholder="请选择课程" style="width: 370px;">
                <el-option v-for="item in courses" :key="item.id" :label="item.name" :value="item.id"/>
            </el-select>
        </el-form-item>
        <el-form-item label="教师" prop="teacherId">
             <el-select v-model="form.teacherId" placeholder="请选择教师" style="width: 370px;">
                <el-option v-for="item in teachers" :key="item.id" :label="item.username" :value="item.id"/>
            </el-select>
        </el-form-item>
        <el-form-item label="学期" prop="teamId">
             <el-input v-model="form.teamId" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="教室" prop="classroom">
          <el-input v-model="form.classroom" style="width: 370px;" />
        </el-form-item>
         <el-form-item label="容量" prop="totalPeople">
          <el-input v-model="form.totalPeople" style="width: 370px;" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="text" @click="crud.cancelCU">取消</el-button>
        <el-button :loading="crud.cu === 2" type="primary" @click="crud.submitCU">确认</el-button>
      </div>
    </el-dialog>
    <!--表格渲染-->
    <el-table ref="table" v-loading="crud.loading" :data="crud.data" size="small" style="width: 100%;" @selection-change="crud.selectionChangeHandler">
      <el-table-column type="selection" width="55" />
      <el-table-column prop="cname" label="课程名称" />
      <el-table-column prop="tname" label="教师" />
      <el-table-column prop="classroom" label="教室" />
      <el-table-column prop="people" label="已选" />
      <el-table-column prop="totalPeople" label="容量" />
      <el-table-column prop="apply" label="审核状态" align="center">
        <template slot-scope="scope">
           <el-tag v-if="scope.row.apply === 1" type="success">已通过</el-tag>
           <el-tag v-else-if="scope.row.apply === 2" type="danger">已驳回</el-tag>
           <el-tag v-else type="warning">待审核</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200px" align="center">
        <template slot-scope="scope">
          <udOperation
            :data="scope.row"
            :permission="permission"
          />
          <el-button v-if="scope.row.apply === 0" size="mini" type="success" @click="handleAgree(scope.row.id)">通过</el-button>
          <el-button v-if="scope.row.apply === 0" size="mini" type="warning" @click="handleBack(scope.row.id)">驳回</el-button>
        </template>
      </el-table-column>
    </el-table>
    <!--分页组件-->
    <pagination />
  </div>
</template>

<script>
import crudTeacherCourse, { agree, back } from '@/api/admin/teacherCourse'
import { listajax as getCourses } from '@/api/admin/course'
import { listajax as getTeachers } from '@/api/admin/teacher'

import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '开课管理', url: 'api/teacherCourse/findApply', idField: 'id', sort: 'id,desc', crudMethod: { ...crudTeacherCourse } })
const defaultForm = { id: null, cid: null, teacherId: null, teamId: '', classroom: '', totalPeople: 50 }

export default {
  name: 'TeacherCourse',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      courses: [],
      teachers: [],
      permission: {
        add: ['admin', 'teacherCourse:add'],
        edit: ['admin', 'teacherCourse:edit'],
        del: ['admin', 'teacherCourse:del']
      },
      rules: {
        cid: [
          { required: true, message: '请选择课程', trigger: 'change' }
        ],
        teacherId: [
          { required: true, message: '请选择教师', trigger: 'change' }
        ]
      }
    }
  },
  methods: {
    [CRUD.HOOK.beforeToCU](crud, form) {
      this.getRefData()
    },
    getRefData() {
        getCourses().then(res => { this.courses = res })
        getTeachers().then(res => { this.teachers = res })
    },
    handleAgree(id) {
        agree(id).then(() => {
            this.$message.success('审核通过')
            this.crud.refresh()
        })
    },
    handleBack(id) {
        back(id).then(() => {
            this.$message.success('驳回成功')
            this.crud.refresh()
        })
    }
  }
}
</script>