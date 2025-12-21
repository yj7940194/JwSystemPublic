<template>
  <div class="app-container">
    <el-card shadow="never" class="mb-2">
      <div slot="header" class="clearfix">
        <span>成绩统计</span>
      </div>
      <el-form inline size="small" label-width="80px">
        <el-form-item label="课程">
          <el-select
            v-model="selectedCourseId"
            filterable
            placeholder="请选择课程"
            style="width: 360px"
            :loading="coursesLoading"
          >
            <el-option v-for="c in courses" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="statsLoading" :disabled="!selectedCourseId" @click="refresh">
            刷新
          </el-button>
        </el-form-item>
      </el-form>

      <el-row :gutter="12" class="summary-row">
        <el-col :span="6">
          <div class="summary-item">
            <div class="label">总人数</div>
            <div class="value">{{ total }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="label">及格人数</div>
            <div class="value">{{ passCount }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="label">不及格人数</div>
            <div class="value">{{ failCount }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="label">及格率</div>
            <div class="value">{{ passRate }}</div>
          </div>
        </el-col>
      </el-row>

      <el-alert
        v-if="!statsLoading && selectedCourseId && !hasStats"
        type="info"
        show-icon
        :closable="false"
        title="当前课程暂无成绩数据（请先录入成绩后再查看统计）"
        class="mt-2"
      />
    </el-card>

    <el-row :gutter="16">
      <el-col :span="14">
        <el-card shadow="never">
          <div slot="header" class="clearfix">
            <span>分数段分布</span>
          </div>
          <div v-loading="statsLoading" class="chart-container">
            <div ref="chart" class="chart" />
            <div v-if="!statsLoading && !hasStats" class="empty">
              <el-empty description="暂无成绩数据" />
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="10">
        <el-card shadow="never">
          <div slot="header" class="clearfix">
            <span>统计明细</span>
          </div>
          <el-table
            v-loading="statsLoading"
            :data="tableRows"
            size="small"
            border
            style="width: 100%"
          >
            <el-table-column prop="range" label="分数段" width="110" />
            <el-table-column prop="count" label="人数" width="80" />
            <el-table-column prop="percent" label="占比" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import echarts from 'echarts'
require('echarts/theme/macarons')
import { debounce } from '@/utils'
import request from '@/utils/request'
import { countCourseScore } from '@/api/common/count'

export default {
  name: 'AdminScore',
  data() {
    return {
      courses: [],
      selectedCourseId: null,
      coursesLoading: false,
      statsLoading: false,
      stats: [],
      chart: null,
      __resizeHandler: null
    }
  },
  computed: {
    ranges() {
      return ['0-59', '60-69', '70-79', '80-89', '90-100']
    },
    total() {
      return (this.stats || []).reduce((sum, n) => sum + (Number(n) || 0), 0)
    },
    failCount() {
      return Number(this.stats && this.stats[0]) || 0
    },
    passCount() {
      const s = this.stats || []
      return (Number(s[1]) || 0) + (Number(s[2]) || 0) + (Number(s[3]) || 0) + (Number(s[4]) || 0)
    },
    passRate() {
      const total = this.total || 0
      return total ? `${((this.passCount / total) * 100).toFixed(2)}%` : '0.00%'
    },
    hasStats() {
      return this.total > 0
    },
    tableRows() {
      const total = this.total || 0
      return this.ranges.map((range, idx) => {
        const count = Number(this.stats && this.stats[idx]) || 0
        const percent = total ? `${((count / total) * 100).toFixed(2)}%` : '0.00%'
        return { range, count, percent }
      })
    }
  },
  watch: {
    selectedCourseId() {
      this.fetchStats()
    }
  },
  async mounted() {
    await this.fetchCourses()
    this.initChart()
    this.__resizeHandler = debounce(() => {
      if (this.chart) this.chart.resize()
    }, 100)
    window.addEventListener('resize', this.__resizeHandler)
  },
  beforeDestroy() {
    if (this.__resizeHandler) window.removeEventListener('resize', this.__resizeHandler)
    if (this.chart) {
      this.chart.dispose()
      this.chart = null
    }
  },
  methods: {
    async fetchCourses() {
      this.coursesLoading = true
      try {
        // 成绩统计使用 teacher_course.id（开课记录）作为 cid
        const res = await request.get('api/course/pageQuery', { params: { offset: 1, limit: 9999 } })
        const rows = (res && res.rows) || []
        const list = Array.isArray(rows) ? rows : []
        this.courses = list
          .map((c) => ({
            id: c && c.id,
            name: c && (c.name || c.courseName || c.cname),
            people: Number(c && c.people) || 0
          }))
          .filter((c) => c && c.id && c.name)
          .sort((a, b) => (b.people || 0) - (a.people || 0))
        if (!this.selectedCourseId && this.courses.length) {
          const preferred = this.courses.find((c) => (c.people || 0) > 0) || this.courses[0]
          this.selectedCourseId = preferred.id
        }
      } catch (e) {
        this.courses = []
        if (this.$message) this.$message.error('获取课程列表失败')
      } finally {
        this.coursesLoading = false
      }
    },
    async fetchStats() {
      if (!this.selectedCourseId) {
        this.stats = []
        this.renderChart()
        return
      }
      this.statsLoading = true
      try {
        const res = await countCourseScore({ cid: this.selectedCourseId })
        const list =
          Array.isArray(res) ? res : res && Array.isArray(res.content) ? res.content : res && Array.isArray(res.data) ? res.data : []
        this.stats = (list || []).map((n) => Number(n) || 0)
        this.renderChart()
      } catch (e) {
        this.stats = []
        this.renderChart()
        if (this.$message) this.$message.error('获取成绩统计失败')
      } finally {
        this.statsLoading = false
      }
    },
    refresh() {
      this.fetchStats()
    },
    initChart() {
      this.$nextTick(() => {
        if (!this.$refs.chart) return
        this.chart = echarts.init(this.$refs.chart, 'macarons')
        this.renderChart()
      })
    },
    renderChart() {
      if (!this.chart) return
      const data = this.ranges.map((r, i) => Number(this.stats && this.stats[i]) || 0)
      this.chart.setOption(
        {
          tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
          grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
          xAxis: [{ type: 'category', data: this.ranges }],
          yAxis: [{ type: 'value', minInterval: 1 }],
          series: [
            {
              name: '人数',
              type: 'bar',
              barWidth: '50%',
              data
            }
          ]
        },
        true
      )
      this.chart.resize()
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

.summary-row {
  margin-top: 8px;
}

.summary-item {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 10px 12px;
  background: #fafafa;
}

.summary-item .label {
  color: #909399;
  font-size: 12px;
  line-height: 18px;
}

.summary-item .value {
  margin-top: 4px;
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  line-height: 24px;
}

.chart-container {
  position: relative;
  min-height: 320px;
}

.chart {
  width: 100%;
  height: 320px;
}

.empty {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}
</style>
