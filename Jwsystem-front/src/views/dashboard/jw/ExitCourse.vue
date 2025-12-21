<template>
  <div :class="className" :style="{height:height,width:width}"/>
</template>

<script>
  import echarts from 'echarts'

  require('echarts/theme/macarons') // echarts theme
  import {debounce} from '@/utils'
  import service from '../../../utils/request'

  const animationDuration = 6000

  export default {
    props: {
      className: {
        type: String,
        default: 'chart'
      },
      data: {
        type: Array,
        default: () => Array.from({ length: 7 }, () => [0, 0, 0, 0, 0])
      },
      width: {
        type: String,
        default: '100%'
      },
      height: {
        type: String,
        default: '300px'
      }
    },
    data() {
      return {
        chart: null,
        trueNum: null,
        total: null,
        falseNum: null,
      }
    },
    watch: {
      data: {
        deep: true,
        handler() {
          if (!this.chart) return
          this.chart.setOption({
            series: [
              { data: this.getSeriesData(0) },
              { data: this.getSeriesData(1) },
              { data: this.getSeriesData(2) },
              { data: this.getSeriesData(3) },
              { data: this.getSeriesData(4) }
            ]
          })
        }
      }
    },
    mounted() {
      this.initChart()
      this.__resizeHandler = debounce(() => {
        if (this.chart) {
          this.chart.resize()
        }
      }, 100)
      window.addEventListener('resize', this.__resizeHandler)
      /*  service.get('/api/count/productIdentify').then(res => {
        this.trueNum = res.trueNum
        this.total = res.total
        this.falseNum = this.total - this.trueNum
        this.chart.setOption({
          series: [{
            data: [{ value: (this.trueNum / this.total * 100).toFixed(2), name: '真假占比' }]
          }]
        })
      })*/
    },
    beforeDestroy() {
      if (!this.chart) {
        return
      }
      window.removeEventListener('resize', this.__resizeHandler)
      this.chart.dispose()
      this.chart = null
    },
    methods: {
      getSeriesData(colIndex) {
        const rows = Array.isArray(this.data) ? this.data : []
        const out = []
        for (let i = 0; i < 7; i++) {
          const row = Array.isArray(rows[i]) ? rows[i] : []
          out.push(Number(row[colIndex] || 0))
        }
        return out
      },
      initChart() {
        this.chart = echarts.init(this.$el, 'macarons')
        this.chart.setOption({
          title: {
            text: "本周考勤情况",
            left: '50%',
            top: '10',
            textStyle: {
              color: 'black',
              fontFamily: 'Courier New'
            }
          },
          tooltip: {
            trigger: 'axis',
            axisPointer: {            // 坐标轴指示器，坐标轴触发有效
              type: 'shadow'        // 默认为直线，可选为：'line' | 'shadow'
            }
          },
          legend: {
            data: ['1-2节', '3-4节', '5-6节', '7-8节', '9-10节'],
            orient: 'vertical',
            left: 10,
            top: 50
          },
          grid: {
            left: '13%',
            bottom: '3%',
            right: 0,
            containLabel: true
          },
          xAxis: [
            {
              type: 'category',
              data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
            }
          ],
          yAxis: [
            {
              type: 'value'
            }
          ],
          series: [
            {
              name: '1-2节',
              type: 'bar',
              data: this.getSeriesData(0)
            },
            {
              name: '3-4节',
              type: 'bar',
              data: this.getSeriesData(1)
            },
            {
              name: '5-6节',
              type: 'bar',
              data: this.getSeriesData(2)
            },
            {
              name: '7-8节',
              type: 'bar',
              data: this.getSeriesData(3)
            },
            {
              name: '9-10节',
              type: 'bar',
              data: this.getSeriesData(4),
            }
          ]
        })
      }
    }
  }
</script>
