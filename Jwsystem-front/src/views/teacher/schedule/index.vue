<template>
  <div class="app-container">
    <el-alert
      title="教师课表"
      type="success"
      :closable="false"
      description="您的本学期授课时间表"
      show-icon
      style="margin-bottom: 20px;"
    />
    
    <el-card>
      <div slot="header" class="clearfix">
        <span>我的课表</span>
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
            <div v-if="cellList(scope.row[index]).length" class="course-cell">
              <div
                v-for="(course, cIndex) in cellList(scope.row[index])"
                :key="cIndex"
                class="course-item"
              >
                <div class="course-name">{{ course.courseName }}</div>
                <div class="course-info">
                  <i class="el-icon-s-custom"></i> {{ course.teacherName }}<br/>
                  <i class="el-icon-location"></i> {{ course.classroom }}
                </div>
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
  name: "TeacherSchedule",
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
    cellList(cell) {
      if (!cell) return []
      if (Array.isArray(cell)) return cell.filter(Boolean)
      return [cell]
    },
    getSchedule() {
      this.loading = true;
      // 复用学生课表的数据处理逻辑，后端返回结构一致
      request.get('/api/teacher/findSchedule')
        .then(res => {
          this.processData(res);
        })
        .catch(err => {
          console.error(err);
        })
        .finally(() => {
          this.loading = false;
        });
    },
    processData(data) {
      if (!data || !Array.isArray(data)) return;
      
      this.tableData = this.sections.map((section, index) => {
        const rowData = {
          section: section.name,
          time: section.time
        };
        
        if (data[index]) {
          data[index].forEach((cellData, dayIndex) => {
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
  background-color: #f0f9eb;
  border-radius: 4px;
  padding: 8px;
  border-left: 4px solid #67C23A;
  text-align: left;
}
.course-item + .course-item {
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed rgba(103, 194, 58, 0.35);
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
