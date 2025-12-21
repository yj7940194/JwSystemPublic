<template>
  <div class="app-container">
    <el-card v-if="!isStudent" shadow="never">
      <div slot="header" class="clearfix">
        <span>学生评价</span>
      </div>
      <el-alert
        type="info"
        show-icon
        :closable="false"
        title="该页面为“学生评价”入口"
        description="当前账号不是学生，无法加载待评任务。请使用学生账号登录进行评价；管理员/教务可前往“发布评价/评价查询”等页面。"
      />
      <div style="margin-top: 12px;">
        <el-button size="small" type="primary" @click="goAdminComment">打开发布评价</el-button>
      </div>
    </el-card>

    <template v-else>
    <el-card shadow="never" class="mb-2">
      <div slot="header" class="clearfix">
        <span>学生评价</span>
      </div>

      <el-form inline size="small" label-width="80px" class="filters">
        <el-form-item label="评价批次">
          <el-select
            v-model="selectedBatchId"
            filterable
            placeholder="请选择评价批次"
            style="width: 420px"
            :loading="batchesLoading"
          >
            <el-option v-for="b in batches" :key="b.id" :label="b.label" :value="b.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="statusFilter" placeholder="全部" style="width: 160px" @change="fetchTasks">
            <el-option label="全部" value="all" />
            <el-option label="待评价" value="todo" />
            <el-option label="已评价" value="done" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" size="small" :disabled="!selectedBatchId" :loading="loading" @click="fetchTasks">
            刷新
          </el-button>
        </el-form-item>
      </el-form>

      <el-alert
        v-if="selectedBatch && selectedBatchOutOfRange"
        type="warning"
        show-icon
        :closable="false"
        title="当前批次不在可评价时间范围内（仍可查看任务，但可能无法提交）"
        class="mt-2"
      />
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="filteredTasks" size="small" border style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column prop="courseName" label="课程" min-width="180" show-overflow-tooltip />
        <el-table-column prop="teacherName" label="教师" width="140" show-overflow-tooltip />
        <el-table-column label="状态" width="110" align="center">
          <template slot-scope="scope">
            <el-tag v-if="Number(scope.row.status) === 1" type="success">已评价</el-tag>
            <el-tag v-else type="warning">待评价</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="得分" width="110" align="center">
          <template slot-scope="scope">
            <span v-if="Number(scope.row.status) === 1">{{ scope.row.remark || 0 }}/100</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" @click="openDetail(scope.row)">
              {{ Number(scope.row.status) === 1 ? '查看' : '评价' }}
            </el-button>
            <el-button
              v-if="Number(scope.row.status) !== 1"
              size="mini"
              :disabled="selectedBatchOutOfRange"
              @click="openDetail(scope.row)"
            >
              填写问卷
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

    <el-dialog :close-on-click-modal="false" :visible.sync="dialogVisible" :title="dialogTitle" width="760px">
      <div v-loading="detailLoading">
        <el-alert
          v-if="activeTask"
          type="info"
          :closable="false"
          show-icon
          :title="`课程：${activeTask.courseName || '-'} / 教师：${activeTask.teacherName || '-'}`"
          class="mb-2"
        />

        <el-form ref="detailForm" :model="detailForm" :rules="rules" label-width="140px" size="small">
          <el-form-item v-for="q in questions" :key="q.key" :label="q.label" :prop="q.key" class="rate-item">
            <el-rate v-model="detailForm[q.key]" show-score text-color="#ff9900" :max="5" />
          </el-form-item>
          <el-form-item label="评价内容" prop="scontent">
            <el-input
              v-model="detailForm.scontent"
              type="textarea"
              :rows="4"
              maxlength="300"
              show-word-limit
              placeholder="请输入评价内容（匿名）"
            />
          </el-form-item>
        </el-form>

        <el-divider />
        <div class="summary">
          <div class="hint">总分（自动计算）：</div>
          <div class="score">{{ computedRemark }}/100</div>
        </div>
      </div>

      <div slot="footer" class="dialog-footer">
        <el-button type="text" @click="dialogVisible = false">关闭</el-button>
        <el-button
          v-if="activeTask && Number(activeTask.status) !== 1"
          type="primary"
          :loading="saving"
          :disabled="selectedBatchOutOfRange"
          @click="submit"
        >
          提交评价
        </el-button>
      </div>
    </el-dialog>
    </template>
  </div>
</template>

<script>
import { listCommentBatches, listTeamComments, queryCourseComment, addCourseComment } from '@/api/student/comment/comment'

export default {
  name: 'StudentComment',
  data() {
    return {
      batchesLoading: false,
      batches: [],
      selectedBatchId: null,

      loading: false,
      tasks: [],
      total: 0,
      page: 1,
      size: 10,
      statusFilter: 'all',

      dialogVisible: false,
      dialogTitle: '评价',
      detailLoading: false,
      saving: false,
      activeTask: null,
      detailForm: {
        q1: 5,
        q2: 5,
        q3: 5,
        q4: 5,
        q5: 5,
        q6: 5,
        q7: 5,
        q8: 5,
        q9: 5,
        q10: 5,
        scontent: ''
      }
    }
  },
  computed: {
    isStudent() {
      const user = this.$store && this.$store.state && this.$store.state.user && this.$store.state.user.user
      return user && user.qx === '学生'
    },
    selectedBatch() {
      return this.batches.find((b) => b.id === this.selectedBatchId) || null
    },
    selectedBatchOutOfRange() {
      if (!this.selectedBatch) return false
      const now = new Date()
      const begin = this.selectedBatch.beginTime ? new Date(this.selectedBatch.beginTime) : null
      const end = this.selectedBatch.endTime ? new Date(this.selectedBatch.endTime) : null
      if (begin && now < begin) return true
      if (end && now > end) return true
      return false
    },
    filteredTasks() {
      const list = this.tasks || []
      if (this.statusFilter === 'todo') return list.filter((t) => Number(t.status) !== 1)
      if (this.statusFilter === 'done') return list.filter((t) => Number(t.status) === 1)
      return list
    },
    questions() {
      return [
        { key: 'q1', label: '1. 教师备课充分，讲授清晰' },
        { key: 'q2', label: '2. 教学内容重点突出，结构合理' },
        { key: 'q3', label: '3. 课堂组织有序，节奏适中' },
        { key: 'q4', label: '4. 教学方法多样，能启发思考' },
        { key: 'q5', label: '5. 课堂互动良好，答疑及时' },
        { key: 'q6', label: '6. 作业布置合理，反馈及时' },
        { key: 'q7', label: '7. 考核方式公平，评价客观' },
        { key: 'q8', label: '8. 教师态度认真，尊重学生' },
        { key: 'q9', label: '9. 课程收获明显，达成学习目标' },
        { key: 'q10', label: '10. 综合评价（推荐程度）' }
      ]
    },
    rules() {
      const base = {
        scontent: [{ required: true, message: '请填写评价内容', trigger: 'blur' }]
      }
      this.questions.forEach((q) => {
        base[q.key] = [{ required: true, message: '请评分', trigger: 'change' }]
      })
      return base
    },
    computedRemark() {
      const sum =
        (Number(this.detailForm.q1) || 0) +
        (Number(this.detailForm.q2) || 0) +
        (Number(this.detailForm.q3) || 0) +
        (Number(this.detailForm.q4) || 0) +
        (Number(this.detailForm.q5) || 0) +
        (Number(this.detailForm.q6) || 0) +
        (Number(this.detailForm.q7) || 0) +
        (Number(this.detailForm.q8) || 0) +
        (Number(this.detailForm.q9) || 0) +
        (Number(this.detailForm.q10) || 0)
      return sum * 2
    }
  },
  watch: {
    selectedBatchId() {
      this.page = 1
      this.fetchTasks()
    }
  },
  created() {
    if (this.isStudent) this.fetchBatches()
  },
  methods: {
    goAdminComment() {
      // 管理端“发布评价”页面（如无权限，会被路由守卫拦截）
      this.$router.push('/admin/comment')
    },
    resetDetailForm() {
      this.detailForm = {
        q1: 5,
        q2: 5,
        q3: 5,
        q4: 5,
        q5: 5,
        q6: 5,
        q7: 5,
        q8: 5,
        q9: 5,
        q10: 5,
        scontent: ''
      }
      if (this.$refs.detailForm) this.$refs.detailForm.clearValidate()
    },
    async fetchBatches() {
      this.batchesLoading = true
      try {
        const res = await listCommentBatches({ offset: 1, limit: 9999 })
        const rows = (res && res.rows) || []
        this.batches = (rows || []).map((b) => {
          const tname = b.tname || ''
          const batch = b.commentBatch || ''
          const begin = b.beginTime || ''
          const end = b.endTime || ''
          return {
            ...b,
            id: b.id,
            label: `${tname} 第${batch}批（${begin}~${end}）`
          }
        })
        if (!this.selectedBatchId && this.batches.length) {
          this.selectedBatchId = this.batches[0].id
        }
      } catch (e) {
        this.batches = []
        if (this.$message) this.$message.error('获取评价批次失败')
      } finally {
        this.batchesLoading = false
      }
    },
    async fetchTasks() {
      if (!this.selectedBatchId) return
      this.loading = true
      try {
        const res = await listTeamComments({ commentId: this.selectedBatchId, offset: this.page, limit: this.size })
        this.tasks = (res && res.rows) || []
        this.total = (res && typeof res.total === 'number' ? res.total : Number(res && res.total)) || 0
      } catch (e) {
        this.tasks = []
        this.total = 0
        if (this.$message) this.$message.error('获取评价任务失败')
      } finally {
        this.loading = false
      }
    },
    onPageChange(p) {
      this.page = p
      this.fetchTasks()
    },
    async openDetail(row) {
      this.activeTask = row
      this.dialogTitle = Number(row.status) === 1 ? '查看评价' : '填写评价'
      this.dialogVisible = true
      this.resetDetailForm()

      // 读取已填写的问卷（如果存在）
      this.detailLoading = true
      try {
        const res = await queryCourseComment({ cid: row.tcid, tcId: row.id })
        if (res && (res.id || res.scontent)) {
          const next = { ...this.detailForm }
          for (let i = 1; i <= 10; i++) {
            const k = `q${i}`
            if (res[k] != null) next[k] = Number(res[k]) || next[k]
          }
          if (res.scontent) next.scontent = res.scontent
          this.detailForm = next
        }
      } catch (e) {
        // ignore: 未评价时可能无记录
      } finally {
        this.detailLoading = false
      }
    },
    submit() {
      if (this.selectedBatchOutOfRange) return
      if (!this.activeTask) return
      if (!this.$refs.detailForm) return
      this.$refs.detailForm.validate(async (valid) => {
        if (!valid) return
        this.saving = true
        try {
          const payload = {
            tmId: String(this.activeTask.id),
            q1: this.detailForm.q1,
            q2: this.detailForm.q2,
            q3: this.detailForm.q3,
            q4: this.detailForm.q4,
            q5: this.detailForm.q5,
            q6: this.detailForm.q6,
            q7: this.detailForm.q7,
            q8: this.detailForm.q8,
            q9: this.detailForm.q9,
            q10: this.detailForm.q10,
            scontent: this.detailForm.scontent
          }
          const res = await addCourseComment(payload)
          if (res && res.code === 0) {
            this.$message.success('提交成功')
            this.dialogVisible = false
            this.fetchTasks()
          } else {
            this.$message.error((res && res.msg) || '提交失败')
          }
        } finally {
          this.saving = false
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

.mt-2 {
  margin-top: 12px;
}

.filters {
  margin-top: 4px;
}

.pagination-container {
  margin-top: 16px;
  text-align: right;
}

.rate-item :deep(.el-form-item__content) {
  display: flex;
  align-items: center;
}

.summary {
  display: flex;
  align-items: baseline;
  justify-content: flex-end;
  gap: 8px;
}

.hint {
  color: #909399;
}

.score {
  font-size: 20px;
  font-weight: 700;
  color: #303133;
}
</style>
