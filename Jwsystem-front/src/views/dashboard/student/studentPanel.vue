<template>
  <div class="student-dashboard">
    <div v-if="user" class="content">
      <el-row :gutter="16">
        <el-col :xs="24" :md="8">
          <el-card shadow="never" class="card">
            <div class="profile">
              <img class="avatar" src="../../../assets/images/avatar-default.svg" alt="avatar"/>
              <div class="name">{{ (user.student && user.student.username) || '学生' }}</div>
              <div class="meta">
                <el-tag size="mini" effect="plain" type="info">{{ user.student && user.student.sex }}</el-tag>
                <el-tag size="mini" effect="plain">{{ user.specialty && user.specialty.name }}</el-tag>
              </div>
            </div>
          </el-card>

          <el-card shadow="never" class="card mt-2">
            <div slot="header" class="card-header">
              <span>学习概览</span>
            </div>
            <div class="metrics">
              <div class="metric">
                <div class="metric-value">{{ user.courseNum }}</div>
                <div class="metric-label">课程数</div>
              </div>
              <div class="metric">
                <div class="metric-value">{{ user.totalTime }}</div>
                <div class="metric-label">总学时</div>
              </div>
              <div class="metric">
                <div class="metric-value">{{ user.upCourseRate }}%</div>
                <div class="metric-label">到课率</div>
              </div>
              <div class="metric">
                <div class="metric-value">{{ user.eligiableRate }}%</div>
                <div class="metric-label">合格率</div>
              </div>
              <div class="metric">
                <div class="metric-value">{{ user.disciplinary }}</div>
                <div class="metric-label">违纪</div>
              </div>
            </div>
          </el-card>

          <el-card shadow="never" class="card mt-2">
            <div slot="header" class="card-header">
              <span>考勤统计</span>
            </div>
            <kao-qin :data="user.absentCount"/>
          </el-card>
        </el-col>

        <el-col :xs="24" :md="16">
          <el-row :gutter="16">
            <el-col :xs="24" :md="12">
              <el-card shadow="never" class="card chart-card">
                <zhnl/>
              </el-card>
            </el-col>
            <el-col :xs="24" :md="12">
              <el-card shadow="never" class="card chart-card">
                <zong-he/>
              </el-card>
            </el-col>
          </el-row>

          <el-row :gutter="16" class="mt-2">
            <el-col :span="24">
              <el-card shadow="never" class="card">
                <cheng-ji
                  :tongshi="user.tongshiRate"
                  :shijian="user.shijanRate"
                  :xueke="user.xuekeRate"
                  :zhuanye="user.zhuanyeRate"
                  :gonggong="user.gonggongRate"
                />
              </el-card>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
    </div>

    <div v-else class="loading">
      <el-skeleton :rows="6" animated/>
    </div>
  </div>
</template>

<script>
import zhnl from './zhnl'
import KaoQin from './KaoQin'
import ChengJi from './ChengJi'
import ZongHe from './ZongHe'
import count from '@/api/count/count'

export default {
  components: {
    zhnl,
    KaoQin,
    ChengJi,
    ZongHe
  },
  data() {
    return {
      user: null
    }
  },
  created() {
    count.findStudentPanel().then(res => {
      this.user = res
    })
  }
}
</script>

<style lang="scss" scoped>
.student-dashboard {
  width: 100%;
}

.loading {
  padding: 16px;
}

.card {
  border-radius: 10px;
}

.mt-2 {
  margin-top: 16px;
}

.profile {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 8px 0 4px;
}

.avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
}

.name {
  margin-top: 10px;
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.meta {
  margin-top: 8px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: center;
}

.metrics {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.metric {
  padding: 10px 12px;
  border: 1px solid rgba(144, 147, 153, 0.15);
  border-radius: 10px;
  background: #fafcff;
}

.metric-value {
  font-size: 20px;
  font-weight: 700;
  color: #0f172a;
  line-height: 24px;
}

.metric-label {
  margin-top: 6px;
  font-size: 12px;
  color: #606266;
}

.chart-card {
  min-height: 260px;
}

@media (max-width: 992px) {
  .metrics {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .metrics {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
