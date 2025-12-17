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
import { findStudentByCourseId, listajax as getCourses } from '@/api/admin/course'
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
          getCourses().then(res => { this.courses = res })
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