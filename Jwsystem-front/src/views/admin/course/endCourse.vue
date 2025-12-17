<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <el-input v-model="query.cname" clearable size="small" placeholder="输入课程名称搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表格渲染-->
    <el-table ref="table" v-loading="crud.loading" :data="crud.data" size="small" style="width: 100%;">
      <el-table-column prop="name" label="课程名称" />
      <el-table-column prop="teacherName" label="申请教师" />
      <el-table-column prop="end" label="状态" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.end === 1">申请结课</el-tag>
          <el-tag v-else-if="scope.row.end === 2" type="success">已同意</el-tag>
          <el-tag v-else-if="scope.row.end === 3" type="danger">已驳回</el-tag>
          <el-tag v-else type="info">进行中</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200px" align="center">
        <template slot-scope="scope">
          <el-button v-if="scope.row.end === 1" size="mini" type="success" @click="handleAudit(scope.row, 'agree')">同意</el-button>
          <el-button v-if="scope.row.end === 1" size="mini" type="danger" @click="handleAudit(scope.row, 'reject')">驳回</el-button>
        </template>
      </el-table-column>
    </el-table>
    <!--分页组件-->
    <pagination />
  </div>
</template>

<script>
import { endApply, updateCourseEnd } from '@/api/admin/course'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '结课申请', url: 'api/course/endApply', idField: 'id', sort: 'id,desc', crudMethod: { list: endApply } })

export default {
  name: 'EndCourse',
  components: { pagination, crudOperation, rrOperation },
  mixins: [presenter(defaultCrud), header(), crud()],
  data() {
    return {
      permission: {
        // add: ['admin', 'course:add'], // No add
        // edit: ['admin', 'course:edit'],
        // del: ['admin', 'course:del']
      }
    }
  },
  methods: {
    handleAudit(row, status) {
      this.$confirm(`确认${status === 'agree' ? '同意' : '驳回'}该结课申请?`, '提示', {
        type: 'warning'
      }).then(() => {
        updateCourseEnd({ id: row.id, endStatus: status, tid: row.tid }).then(() => {
          this.$message.success('操作成功')
          this.crud.refresh()
        })
      })
    }
  }
}
</script>
