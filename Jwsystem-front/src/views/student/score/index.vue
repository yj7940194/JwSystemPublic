<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>我的成绩单</span>
      </div>
      
      <el-table
        :data="dataList"
        v-loading="loading"
        border
        style="width: 100%">
        <el-table-column label="序号" type="index" width="50" align="center"/>
        <el-table-column prop="courseName" label="课程名称" min-width="150"/>
        <el-table-column prop="usually" label="平时" width="80" align="center"/>
        <el-table-column prop="exam" label="考试" width="80" align="center"/>
        <el-table-column prop="score" label="总评" width="80" align="center">
          <template slot-scope="scope">
            <span :style="{color: scope.row.score >= 60 ? '#67C23A' : '#F56C6C', fontWeight: 'bold'}">
              {{ scope.row.score }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="point" label="绩点" width="80" align="center"/>
        <el-table-column label="状态" width="100" align="center">
          <template slot-scope="scope">
            <el-tag :type="scope.row.score >= 60 ? 'success' : 'danger'" size="mini">
              {{ scope.row.score >= 60 ? '及格' : '不及格' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: "StudentScore",
  data() {
    return {
      dataList: [],
      loading: false
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      request.get('/api/score/findStudentScore')
        .then(res => {
          const payload = res && res.data ? res.data : res;

          // 处理不同的返回结构
          let scoreData = [];
          // MyBatis-Plus IPage格式: {records: [], total: 0}
          if (payload && payload.records && Array.isArray(payload.records)) {
            scoreData = payload.records;
          }
          // 普通分页格式: {rows: [], total: 0}
          else if (payload && payload.rows && Array.isArray(payload.rows)) {
            scoreData = payload.rows;
          }
          // 直接数组
          else if (Array.isArray(payload)) {
            scoreData = payload;
          }
          // 单个对象
          else if (payload && typeof payload === 'object') {
            scoreData = [payload];
          }

          this.dataList = scoreData;
          
          if (this.dataList.length === 0) {
            this.$message.warning('暂无成绩数据');
          }
        })
        .catch(err => {
          console.error('获取成绩失败:', err);
          const errMsg = err && err.response && err.response.data && err.response.data.message
            ? err.response.data.message
            : (err && err.message ? err.message : String(err));
          this.$message.error('获取成绩失败: ' + errMsg);
        })
        .finally(() => {
          this.loading = false;
        });
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
