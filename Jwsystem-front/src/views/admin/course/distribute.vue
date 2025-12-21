<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <el-select v-model="query.id" filterable placeholder="请选择课程查询" style="width: 200px;" class="filter-item" @change="crud.toQuery">
            <el-option v-for="item in courses" :key="item.id" :label="item.name" :value="item.id"/>
        </el-select>
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表格渲染-->
    <el-table ref="table" v-loading="crud.loading" :data="crud.data" size="small" style="width: 100%;">
      <el-table-column prop="sid" label="学号" />
      <el-table-column prop="sname" label="姓名" />
      <el-table-column prop="classname" label="班级" />
      <el-table-column prop="sex" label="性别" />
      <el-table-column prop="phone" label="手机号" />
    </el-table>
    <!--分页组件-->
    <pagination />
  </div>
</template>

<script>
import { findStudentByCourseId } from '@/api/admin/course'
import request from '@/utils/request'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '选课分配', url: 'api/course/findStudentByCourseId', idField: 'sid', crudMethod: { list: findStudentByCourseId } })

export default {
  name: 'Distribute',
  components: { pagination, crudOperation, rrOperation },
  mixins: [presenter(defaultCrud), header(), crud()],
  data() {
    return {
      courses: [],
      permission: {}
    }
  },
  created() {
      this.getCourses()
  },
  methods: {
      getCourses() {
          // 分配需要选择“开课记录”(teacher_course.id)，而不是基础课程(t_course.id)
          // 复用后端 /api/course/pageQuery，返回的 rows 中 id 为 teacher_course.id，name 为课程名
          request.get('api/course/pageQuery', { params: { offset: 1, limit: 9999 } }).then(res => {
            const rows = (res && res.rows) || []
            const list = Array.isArray(rows) ? rows : []
            this.courses = list
              .map(r => ({ id: r && r.id, name: r && r.name, people: Number(r && r.people) || 0 }))
              .filter(r => r && r.id && r.name)
              .sort((a, b) => (b.people || 0) - (a.people || 0))
            if (!this.query.id && this.courses.length) {
              const preferred = this.courses.find(c => (c.people || 0) > 0) || this.courses[0]
              this.query.id = preferred.id
              // 自动加载首个课程的学生列表，避免页面一进来就是“暂无数据”
              this.$nextTick(() => this.crud.toQuery())
            }
          }).catch(() => { this.courses = [] })
      },
      [CRUD.HOOK.beforeRefresh](crud) {
          if (!crud.query.id) {
              this.$message.warning('请先选择课程')
              return false
          }
      }
  }
}
</script>
