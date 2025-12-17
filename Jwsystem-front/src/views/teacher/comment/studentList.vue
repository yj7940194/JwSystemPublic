<template>
  <div class="app-container">
    <el-card shadow="never" class="mb-2">
      <div slot="header" class="clearfix">
        <span>学生评价列表</span>
      </div>

      <el-form inline size="small" label-width="80px" class="filters">
        <el-form-item label="课程">
          <el-input v-model="courseName" disabled placeholder="(从列表进入)" style="width: 320px" />
        </el-form-item>

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

        <el-form-item>
          <el-button type="primary" size="small" :disabled="!selectedBatchId || !courseTcid" :loading="loading" @click="fetchStudents">
            刷新
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="dataList" size="small" border style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center" />
        <el-table-column prop="sid" label="学号" width="120" />
        <el-table-column prop="sname" label="姓名" min-width="160" />
        <el-table-column label="状态" width="110" align="center">
          <template slot-scope="scope">
            <el-tag v-if="Number(scope.row.status) === 1" type="success">已评价</el-tag>
            <el-tag v-else type="warning">未评价</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="得分" width="120" align="center">
          <template slot-scope="scope">
            <span v-if="Number(scope.row.status) === 1">{{ scope.row.remark || 0 }}/100</span>
            <span v-else>-</span>
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
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'TeacherStudentCommentList',
  data() {
    return {
      batchesLoading: false,
      batches: [],
      selectedBatchId: null,

      courseTcid: '',
      courseName: '',

      loading: false,
      dataList: [],
      total: 0,
      page: 1,
      size: 10
    }
  },
  watch: {
    selectedBatchId() {
      this.page = 1
      this.fetchStudents()
    }
  },
  created() {
    const q = this.$route && this.$route.query ? this.$route.query : {}
    this.courseTcid = q.cid || ''
    this.courseName = q.courseName || ''
    this.selectedBatchId = q.commentId || null
    this.fetchBatches()
  },
  methods: {
    async fetchBatches() {
      this.batchesLoading = true
      try {
        const res = await request.get('/api/comment/pageQuery', { params: { offset: 1, limit: 9999 } })
        const rows = (res && res.rows) || []
        this.batches = rows.map((b) => {
          const tname = b.tname || ''
          const batch = b.commentBatch || ''
          const begin = b.beginTime || ''
          const end = b.endTime || ''
          return { ...b, id: b.id, label: `${tname} 第${batch}批（${begin}~${end}）` }
        })
        if (!this.selectedBatchId && this.batches.length) this.selectedBatchId = this.batches[0].id
      } catch (e) {
        this.batches = []
        if (this.$message) this.$message.error('获取评价批次失败')
      } finally {
        this.batchesLoading = false
      }
    },
    fetchStudents() {
      if (!this.selectedBatchId || !this.courseTcid) return
      this.loading = true
      request
        .get('/api/teamComment/findStudentComment', { params: { commentId: this.selectedBatchId, cid: this.courseTcid, offset: this.page, limit: this.size } })
        .then((res) => {
          this.dataList = (res && res.rows) || []
          this.total = (res && typeof res.total === 'number' ? res.total : Number(res && res.total)) || 0
        })
        .catch(() => {
          this.dataList = []
          this.total = 0
          if (this.$message) this.$message.error('获取学生评价列表失败')
        })
        .finally(() => {
          this.loading = false
        })
    },
    onPageChange(p) {
      this.page = p
      this.fetchStudents()
    }
  }
}
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.pagination-container {
  margin-top: 20px;
  text-align: right;
}
</style>

