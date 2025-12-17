<template>
  <div class="app-container">
    <el-card shadow="never" class="mb-2">
      <div slot="header" class="clearfix">
        <span>发布评价</span>
      </div>
      <el-alert
        type="info"
        show-icon
        :closable="false"
        title="新增评价批次后，系统会按所选学期为课程与学生生成评教任务"
      />
      <div class="toolbar">
        <el-button type="primary" size="small" @click="openAdd">新增批次</el-button>
        <el-button size="small" :loading="loading" @click="fetchList">刷新</el-button>
      </div>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="list" size="small" border style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column prop="commentBatch" label="批次" width="100" />
        <el-table-column prop="tname" label="学期" min-width="180" show-overflow-tooltip />
        <el-table-column prop="commentType" label="类型" width="120" align="center">
          <template slot-scope="scope">
            <el-tag v-if="Number(scope.row.commentType) === 0" type="success">课程评教</el-tag>
            <el-tag v-else type="info">类型{{ scope.row.commentType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="beginTime" label="开始日期" width="120" align="center" />
        <el-table-column prop="endTime" label="结束日期" width="120" align="center" />
        <el-table-column label="操作" width="180" align="center">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" @click="openEdit(scope.row)">编辑</el-button>
            <el-button size="mini" type="danger" :loading="deletingId === scope.row.id" @click="onDelete(scope.row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          background
          :current-page="page"
          :page-size="size"
          layout="total, prev, pager, next"
          :total="total"
          @current-change="onPageChange"
        />
      </div>
    </el-card>

    <el-dialog :close-on-click-modal="false" :visible.sync="dialogVisible" :title="dialogTitle" width="560px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="90px">
        <el-form-item label="学期" prop="teamId">
          <el-select v-model="form.teamId" filterable placeholder="请选择学期" style="width: 360px" :loading="teamsLoading">
            <el-option v-for="t in teams" :key="t.id" :label="t.name" :value="t.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="批次" prop="commentBatch">
          <el-input v-model="form.commentBatch" placeholder="例如：1 / 2025春季" style="width: 360px" />
        </el-form-item>
        <el-form-item label="类型" prop="commentType">
          <el-select v-model="form.commentType" placeholder="请选择" style="width: 160px">
            <el-option :value="0" label="课程评教" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="beginTime">
          <el-date-picker
            v-model="form.beginTime"
            type="date"
            placeholder="选择日期"
            style="width: 160px"
            value-format="yyyy-MM-dd"
          />
        </el-form-item>
        <el-form-item label="结束日期" prop="endTime">
          <el-date-picker
            v-model="form.endTime"
            type="date"
            placeholder="选择日期"
            style="width: 160px"
            value-format="yyyy-MM-dd"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="text" @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSubmit">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import request from '@/utils/request'
import { pageQuery, add, edit, del } from '@/api/admin/comment/comment'

export default {
  name: 'AdminComment',
  data() {
    return {
      loading: false,
      list: [],
      total: 0,
      page: 1,
      size: 10,

      teamsLoading: false,
      teams: [],

      dialogVisible: false,
      dialogTitle: '新增批次',
      saving: false,
      deletingId: null,
      form: {
        id: null,
        teamId: null,
        commentType: 0,
        commentBatch: '',
        beginTime: '',
        endTime: ''
      },
      rules: {
        teamId: [{ required: true, message: '请选择学期', trigger: 'change' }],
        commentBatch: [{ required: true, message: '请输入批次', trigger: 'blur' }],
        beginTime: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
        endTime: [{ required: true, message: '请选择结束日期', trigger: 'change' }]
      }
    }
  },
  created() {
    this.fetchTeams()
    this.fetchList()
  },
  methods: {
    async fetchTeams() {
      this.teamsLoading = true
      try {
        const res = await request({
          url: 'api/team/pageQuery',
          method: 'get',
          params: { offset: 1, limit: 9999 }
        })
        const rows = res && res.rows ? res.rows : []
        this.teams = Array.isArray(rows) ? rows : []
      } finally {
        this.teamsLoading = false
      }
    },
    async fetchList() {
      this.loading = true
      try {
        const res = await pageQuery({ offset: this.page, limit: this.size })
        this.list = (res && res.rows) || []
        this.total = (res && typeof res.total === 'number' ? res.total : Number(res && res.total)) || 0
      } finally {
        this.loading = false
      }
    },
    onPageChange(p) {
      this.page = p
      this.fetchList()
    },
    resetForm() {
      this.form = {
        id: null,
        teamId: null,
        commentType: 0,
        commentBatch: '',
        beginTime: '',
        endTime: ''
      }
      if (this.$refs.form) this.$refs.form.clearValidate()
    },
    openAdd() {
      this.dialogTitle = '新增批次'
      this.resetForm()
      this.dialogVisible = true
    },
    openEdit(row) {
      this.dialogTitle = '编辑批次'
      this.resetForm()
      this.form.id = row && row.id
      this.form.teamId = row && row.teamId
      this.form.commentType = row && (row.commentType === 0 || row.commentType) ? Number(row.commentType) : 0
      this.form.commentBatch = row && row.commentBatch
      this.form.beginTime = row && row.beginTime
      this.form.endTime = row && row.endTime
      this.dialogVisible = true
    },
    onSubmit() {
      if (!this.$refs.form) return
      this.$refs.form.validate(async (valid) => {
        if (!valid) return
        this.saving = true
        try {
          const payload = {
            id: this.form.id,
            teamId: this.form.teamId,
            commentType: this.form.commentType,
            commentBatch: this.form.commentBatch,
            beginTime: this.form.beginTime,
            endTime: this.form.endTime
          }
          const res = this.form.id ? await edit(payload) : await add(payload)
          if (res && res.code === 0) {
            this.$message.success('保存成功')
            this.dialogVisible = false
            this.fetchList()
          } else {
            this.$message.error((res && res.msg) || '保存失败')
          }
        } finally {
          this.saving = false
        }
      })
    },
    onDelete(row) {
      this.$confirm('确认删除该评价批次？（已生成的评教任务将一并删除）', '提示', { type: 'warning' }).then(async () => {
        this.deletingId = row.id
        try {
          const res = await del(row.id)
          if (res && res.code === 0) {
            this.$message.success('删除成功')
            if (this.list.length === 1 && this.page > 1) this.page -= 1
            this.fetchList()
          } else {
            this.$message.error((res && res.msg) || '删除失败')
          }
        } finally {
          this.deletingId = null
        }
      })
    }
  }
}
</script>

<style scoped>
.mb-2 {
  margin-bottom: 12px;
}

.toolbar {
  margin-top: 12px;
  display: flex;
  gap: 8px;
}

.pagination-container {
  margin-top: 16px;
  text-align: right;
}
</style>
