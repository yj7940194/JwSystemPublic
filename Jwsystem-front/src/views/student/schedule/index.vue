<template>
  <div class="app-container">
    <el-alert
      title="我的课表"
      type="success"
      :closable="false"
      description="实时获取最新教务课表数据"
      show-icon
      style="margin-bottom: 20px;"
    />
    
    <el-card>
      <div slot="header" class="clearfix">
        <span>本学期课表</span>
        <el-tag type="info" style="float: right">当前第 {{ currentWeek }} 周</el-tag>
      </div>
      
      <el-table
        :data="tableData"
        border
        style="width: 100%"
        v-loading="loading">
        <el-table-column prop="section" label="节次" width="100" align="center" fixed bg-color="#f5f7fa">
          <template slot-scope="scope">
            <div style="font-weight: bold">{{ scope.row.section }}</div>
            <div style="font-size: 12px; color: #909399">{{ scope.row.time }}</div>
          </template>
        </el-table-column>
        
        <el-table-column v-for="(day, index) in weekDays" :key="index" :label="day" align="center" min-width="120">
          <template slot-scope="scope">
            <div v-if="scope.row[index]" class="course-cell">
              <div class="course-name">{{ scope.row[index].courseName }}</div>
              <div class="course-info">
                <i class="el-icon-user"></i> {{ scope.row[index].teacherName }}<br/>
                <i class="el-icon-location"></i> {{ scope.row[index].classroom }}
              </div>
            </div>
            <div v-else class="empty-cell"></div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: "StudentSchedule",
  data() {
    return {
      weekDays: ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'],
      sections: [
        { name: '1-2节', time: '08:00-09:40' },
        { name: '3-4节', time: '10:00-11:40' },
        { name: '5-6节', time: '14:00-15:40' },
        { name: '7-8节', time: '16:00-17:40' },
        { name: '9-10节', time: '19:00-20:40' }
      ],
      tableData: [],
      loading: false,
      currentWeek: 1
    };
  },
  mounted() {
    this.getSchedule();
  },
  methods: {
    getSchedule() {
      this.loading = true;
      // 调用后端API获取5x7的二维数组
      request.get('/api/student/findSchedule')
        .then(res => {
          this.processData(res);
        })
        .catch(err => {
          console.error(err);
          this.$message.error('获取课表失败');
        })
        .finally(() => {
          this.loading = false;
        });
    },
    processData(data) {
      if (!data || !Array.isArray(data)) return;
      
      // 将二维数组转换为表格数据
      // 后端返回的是 [5行][7列] 的数组
      this.tableData = this.sections.map((section, index) => {
        const rowData = {
          section: section.name,
          time: section.time
        };
        
        // 映射每一天的数据
        if (data[index]) {
          data[index].forEach((cellData, dayIndex) => {
            // 注意：后端可能返回null或对象
            rowData[dayIndex] = cellData;
          });
        }
        
        return rowData;
      });
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.course-cell {
  background-color: #ecf5ff;
  border-radius: 4px;
  padding: 8px;
  border-left: 4px solid #409EFF;
  text-align: left;
}
.course-name {
  font-weight: bold;
  color: #303133;
  margin-bottom: 4px;
}
.course-info {
  font-size: 12px;
  color: #606266;
  line-height: 1.4;
}
.empty-cell {
  height: 60px;
}
</style>
