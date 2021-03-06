<template>
  <div class='plot content'>
    <div class="tile is-ancestor">
      <div class="tile is-2 is-parent">
        <div class="tile is-child">
          <div class="field">
            <label class="label">Group</label>
            <div class="select is-fullwidth">
              <select v-model='selectedGroup' :disabled='prioritySelected'>
                <option v-for="option in groupList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label class="label">Sub-group</label>
            <div class="select is-fullwidth">
              <select v-model='selectedSubGroup' :disabled='prioritySelected || !subGroupEnabled'>
                <option v-for="option in subGroupList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label class="label">State / Territory</label>
            <div class="select is-fullwidth">
              <select v-model='selectedState' :disabled='prioritySelected'>
                <option v-for="option in stateList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label class="label">Status authority</label>
            <div class="select is-fullwidth">
              <select v-model='selectedStatusAuthority' :disabled='prioritySelected'>
                <option v-for="option in statusAuthorityList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label class="label">Status</label>
            <div class="select is-fullwidth">
              <select v-model='selectedStatus' :disabled='prioritySelected'>
                <option v-for="option in statusList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label class="label">Reference year</label>
            <div class="select is-fullwidth">
              <select v-model='selectedYear'>
                <option v-for="option in yearList" v-bind:value="option">{{option.text}}</option>
              </select>
            </div>
          </div>

          <div class="field">
            <input type="checkbox" id="checkbox" v-model="prioritySelected">
            <label for="checkbox">National priority species</label>
          </div>

          <p>
            <button class='button is-primary is-small' v-on:click='downloadCSV'>Download CSV</button>
          </p>
          <p>
            <button class='button is-primary is-small' v-on:click='viewDataSummary'>Data Summary</button>
          </p>
        </div>
      </div>

      <div class="modal is-active" v-show='loadingData && !showFullMap'>
        <div class="modal-background" style="background: rgba(0,0,0,0.2)"></div>
        <div class="modal-card">
          <section class="modal-card-body">
            <spinner size='large' message='Loading data....'></spinner>
          </section>
        </div>
      </div>

      <div class="tile is-vertical ie11-bugfix" v-show="!noData">
        <div class="tile">
          <div class="tile is-parent is-vertical" v-show="!showFullMap">
            <div class="tile is-child card">
              <h4 class="has-text-black">Main index</h4>
              <span class="info-icon icon"
                data-tippy-html="#popup-main-index"
                data-tippy-interactive="true"
                data-tippy-arrow="true"
                data-tippy-placement="left"
                v-tippy>
                <i class="far fa-question-circle"></i>
              </span>
              <div id="popup-main-index" style="display: none" v-tippy-html>
                  <div class="popup-content">
                      <p>The index shows the average change in populations compared to a base year. It shows a relative change and not population numbers themselves. At the reference year, the index gets an index score of one. A score of 1.2 would mean a 20% increase on average compared to the reference year, while a score of 0.8 would mean a 20% decrease on average compared to the reference year.</p>
                      <p>Check this index:</p>
                      <ol>
                        <li>Look at <b>Spatial representativeness</b> map to see how much data there are and where these data come from.</li>
                        <li>Look at <b>Monitoring consistency</b> to see how consistently each monitoring location was visited over time.</li>
                        <li>Go to <b>Time series and species accumulation</b> plot to see how many time series and species/subspecies were used to calculate this index in each year</li>
                        <li>Adjust the <b>Reference year</b> to let the index start at a year with more data</li>
                        <li>Go to <b>Data Summary</b> to see which species/subspecies were included in this index</li>
                        <li>Go to <b>Download CSV</b> to get the aggregated data used to calculate this index.</li>
                      </ol>
                  </div>
              </div>
              <div class="plot-container" v-show="!noLPI">
                <canvas ref='lpiplot'></canvas>
              </div>
              <div class="has-text-black" v-show="noLPI">
                <p>No index generated – less than 3 taxa present in the range of reference years.</p>
                <p>Try changing the reference year to build an index</p>
              </div>
            </div>
            <div class="tile is-child card">
                <h4 class="has-text-black">Monitoring consistency</h4>
                <span class="info-icon icon"
                data-tippy-html="#popup-monitoring-consistency"
                data-tippy-interactive="true"
                data-tippy-arrow="true"
                data-tippy-placement="left"
                v-tippy>
                  <i class="far fa-question-circle"></i>
                </span>
                <div id="popup-monitoring-consistency" style="display: none" v-tippy-html>
                    <div class="popup-content">
                      This dot plot shows the particular years for which monitoring data were available. Each row represents a time series where a species/subspecies was monitored with a consistent method at a single site. The dots represent count values for the metric used to quantify the species/subspecies while zeros indicate absences (non-detections) of those species at the site.
                    </div>
                </div>
                <div class="plot-container">
                  <canvas ref='dotplot'></canvas>
                </div>
            </div>
          </div>
          <div class="tile is-parent is-vertical">
            <div class="tile is-child card map-tile">
              <h4 class="has-text-black">Spatial representativeness</h4>
              <span class="info-icon icon"
                data-tippy-html="#popup-spatial-rep"
                data-tippy-interactive="true"
                data-tippy-arrow="true"
                data-tippy-placement="left"
                v-tippy>
                <i class="far fa-question-circle"></i>
              </span>
              <div id="popup-spatial-rep" style="display: none" v-tippy-html>
                  <div class="popup-content">
                    This map shows where threatened species data to calculate this index are recorded in Australia. Light blue indicates less data (fewer sites monitored), pink indicates more data (more sites monitored).
                  </div>
              </div>
              <vue-slider ref='slider' v-bind='sliderData' v-model='sliderRange' v-if='sliderEnabled' class='heatmap-slider'></vue-slider>
              <div id='intensityplot' ref='intensityplot' class='heatmap-div'></div>
              <spinner size='medium' v-show='loadingMap' class='heatmap-spinner'></spinner>
            </div>
            <div class="tile is-child card" v-show="!showFullMap">
              <h4 class="has-text-black">Time series and species accumulation</h4>
              <span class="info-icon icon"
                data-tippy-html="#popup-summary-plot"
                data-tippy-interactive="true"
                data-tippy-arrow="true"
                data-tippy-placement="left"
                v-tippy>
                <i class="far fa-question-circle"></i>
              </span>
              <div id="popup-summary-plot" style="display: none" v-tippy-html>
                  <div class="popup-content">
                    This plot shows the number of species/subspecies (in blue) and the number of time series (in green) used to calculate the index for each year.
                  </div>
              </div>
              <div class="plot-container">
                <canvas ref='sumplot'></canvas>
              </div>
            </div>

          </div>
        </div>
      </div>

      <div class="tile is-child" v-show="noData">
        <p style="margin: 0.8em">(No data to show)</p>
      </div>
    </div>

    <!-- warning dialog -->
    <div class="modal is-active" v-show="!hasAcceptedWarning">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <span class="modal-card-title">Caution</span>
        </header>
        <section class="modal-card-body" style="color:black">
          <p>The trends produced by this tool vary in reliability.</p>
          <p>A trend is only as good as the data used to generate it.</p>
          <p>We have developed diagnostic tools to help assess the reliability of each trend. <a target="_blank" rel="noopener noreferrer" href="https://tsx.org.au/visualising-the-index/how-good/">(Click here for more details on how to assess reliability of trends)</a></p>
          <p>By using this tool you acknowledge these precautions and agree to apply common sense whenever using the TSX.</p>
        </section>
        <footer class="modal-card-foot">
          <button class="button" v-on:click='acceptWarning'>I Accept</button>
          <button class="button" v-on:click='goBack'>Cancel</button>
        </footer>
      </div>
    </div>
  </div>
</template>
<script>
import * as api from '@/api'
import Chart from 'chart.js'
import Spinner from 'vue-simple-spinner'
import L from 'leaflet'
import HeatmapOverlay from 'heatmap.js/plugins/leaflet-heatmap/leaflet-heatmap.js'
import easyButton from 'leaflet-easybutton/src/easy-button.js'
import vueSlider from 'vue-slider-component/dist/index.js'
import { min, max, pluck } from '@/util'

const subGroups = [
    {value: 'None', text: 'All'},
    // {value: 'Tropicbirds Frigatebirds Gannets Boobies', text: 'Tropicbirds Frigatebirds Gannets Boobies'},
    // {value: 'Gulls Terns Noddies Skuas Jaegers', text: 'Gulls Terns Noddies Skuas Jaegers'},
    // {value: 'Rainforest', text: 'Rainforest'},
    // {value: 'Penguins', text: 'Penguins'},
    {value: 'Tropical savanna woodland', text: 'Tropical savanna woodland', group: 'Terrestrial'},
    // {value: 'Island endemic', text: 'Island endemic'},
    // {value: 'Petrels and Shearwaters', text: 'Petrels and Shearwaters'},
    // {value: 'Grassland', text: 'Grassland'},
    {value: 'Albatrosses and Giant-Petrels', text: 'Albatrosses and Giant-Petrels', group: 'Marine'},
    {value: 'Dry sclerophyll woodland/forest', text: 'Dry sclerophyll woodland/forest', group: 'Terrestrial'}
    // {value: 'Arid Woodland/ shrubland', text: 'Arid Woodland/ shrubland'},
    // {value: 'Heathland', text: 'Heathland'},
    // {value: 'Mallee woodland', text: 'Mallee woodland'}
]

export default {
  name: 'TSX',
  components: {
    Spinner, easyButton, vueSlider
  },
  data () {
    var data = {
      // group
      groupList: [],
      selectedGroup: {value: 'None', text: 'All'},
      // subgroup
      subGroupList: [],
      selectedSubGroup: subGroups[0],
      subGroupEnabled: true,
      // states
      stateList: [],
      selectedState: {value: 'None', text: 'All'},
      // status auth
      statusAuthorityList: [],
      selectedStatusAuthority: {value: 'Max', text: 'Max'},
      // status
      statusList: [],
      selectedStatus: {value: 'Near Threatened+Vulnerable+Endangered+Critically Endangered', text: 'All (all Near Threatened + Vulnerable + Endangered + Critically Endangered)'},
      // year
      yearList: [],
      selectedYear: {value: '1985', text: '1985'},
      // charts
      dotPlot: null,
      dotPlotDataSet: null,
      // lpi plot
      lpiPlot: null,
      lpiPlotDataSet: null,
      // summayplot
      summaryPlotDataSet: null,
      summaryPlot: null,
      // is loading data
      loadingData: false,
      // need to query LPI rest service
      queryLPIData: true,
      // no data to show
      noData: true,
      // no LPI run to show
      noLPI: false,
      // prioritySelected
      prioritySelected: false,
      // heatmap
      // intensity plot
      loadingMap: false,
      heatmapLayer: null,
      // this stores the data from the API, heatmapDataSet.data contains subset of it
      surveyData: [],
      heatmapDataSet: {max: 0, min: 0, data: []},
      map: null,
      showFullMap: false,
      sliderRange: [1960, 2017],
      sliderData: {
        eventType: 'auto',
        width: 'auto',
        height: 4,
        dotSize: 14,
        min: 1960,
        max: 2020,
        interval: 1,
        disabled: false,
        show: false,
        lazy: true,
        tooltip: 'always'
      },
      sliderEnabled: false,
      hasAcceptedWarning: localStorage.getItem('hasAcceptedWarning') || false
    }
    // groups
    data.groupList.push({value: 'None', text: 'All'})
    data.groupList.push({value: 'Terrestrial', text: 'Terrestrial'})
    data.groupList.push({value: 'Wetland', text: 'Wetland'})
    data.groupList.push({value: 'Marine', text: 'Marine'})
    data.groupList.push({value: 'Shoreline (migratory)', text: 'Shoreline (migratory)'})
    // data.groupList.push({value: 'Shoreline (resident)', text: 'Shoreline (resident)'})
    // subgroups
    data.subGroupList = subGroups
    // states filter
    data.stateList.push({value: 'None', text: 'All'})
    data.stateList.push({value: 'Australian Capital Territory', text: 'Australian Capital Territory'})
    // data.stateList.push({value: 'Commonwealth', text: 'Commonwealth'})
    data.stateList.push({value: 'Queensland', text: 'Queensland'})
    data.stateList.push({value: 'New South Wales', text: 'New South Wales'})
    data.stateList.push({value: 'Australian Capital Territory+New South Wales', text: 'Australian Capital Territory + New South Wales'})
    data.stateList.push({value: 'Northern Territory', text: 'Northern Territory'})
    data.stateList.push({value: 'South Australia', text: 'South Australia'})
    data.stateList.push({value: 'Western Australia', text: 'Western Australia'})
    data.stateList.push({value: 'Tasmania', text: 'Tasmania'})
    data.stateList.push({value: 'Victoria', text: 'Victoria'})
    // status auth
    data.statusAuthorityList.push({value: 'Max', text: 'Max'})
    data.statusAuthorityList.push({value: 'EPBC', text: 'EPBC'})
    // data.statusAuthorityList.push({value: 'IUCN', text: 'IUCN'})
    data.statusAuthorityList.push({value: 'BirdLifeAustralia', text: 'Australian IUCN status'})
    // year
    data.yearList.push({value: '1985', text: '1985'})
    data.yearList.push({value: '1990', text: '1990'})
    data.yearList.push({value: '1995', text: '1995'})
    data.yearList.push({value: '2000', text: '2000'})
    // status
    data.statusList.push({value: 'Vulnerable+Endangered+Critically Endangered', text: 'Threatened species (all Vulnerable + Endangered + Critically Endangered)'})
    data.statusList.push({value: 'Near Threatened+Vulnerable+Endangered+Critically Endangered', text: 'All (all Near Threatened + Vulnerable + Endangered + Critically Endangered)'})
    data.statusList.push({value: 'Near Threatened', text: 'Near Threatened species (Near Threatened species only)'})
    // data.statusList.push({value: 'Near Threatened', text: 'Near Threatened'})
    // data.statusList.push({value: 'Vulnerable', text: 'Vulnerable'})
    // data.statusList.push({value: 'Endangered', text: 'Endangered'})
    // data.statusList.push({value: 'Critically Endangered', text: 'Critically Endangered'})
    return data
  },
  mounted: function() {
    var that = this
    Chart.defaults.global.defaultFontSize = 14
    // ---------- dot plot -------------
    this.dotPlotDataSet = {
      datasets: [{
        label: 'count > 0',
        backgroundColor: '#333',
        borderColor: '#333',
        borderWidth: 1,
        data: [] },
      {
        label: 'count = 0',
        backgroundColor: '#ccc',
        borderColor: '#ccc',
        borderWidth: 1,
        data: [] }]
    }
    this.dotPlot = new Chart.Bubble(this.$refs.dotplot.getContext('2d'), {
      data: that.dotPlotDataSet,
      // Configuration options go here
      options: {
        animation: false,
        responsive: true,
        maintainAspectRatio: false,
        tooltips: {
          mode: 'point'
        },
        scales: {
          yAxes: [{
            type: 'linear',
            display: true,
            position: 'left',
            scaleLabel: {
              display: true,
              labelString: 'Sites (time series)'
            }
          }],
          xAxes: [{
            type: 'linear'
          }]
        }
      }
    })
    // --------- summary plot ------------
    this.summaryPlotDataSet = {
      datasets: [{
        label: 'Number of taxa',
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-1',
        borderColor: '#58899e',
        backgroundColor: '#58899e',
        data: []
      }, {
        label: 'Number of time series',
        xAxisID: 'x-axis-1',
        yAxisID: 'y-axis-2',
        borderColor: '#a3c489',
        backgroundColor: '#a3c489',
        data: []
      }]
    }
    // --------- lpi plot ------------
    this.lpiPlotDataSet = {
      labels: [],
      datasets: [{
        label: 'TSX',
        borderColor: '#36699e',
        backgroundColor: 'black',
        fill: false,
        pointRadius: 0,
        lineTension: 0,
        data: [] },
      {
        label: 'Confidence Interval (low)',
        backgroundColor: 'rgba(230,230,230,0.5)',
        fill: 1,
        pointRadius: 0,
        lineTension: 0,
        borderColor: '#0000',
        borderWidth: 0,
        data: [] },
      {
        label: 'Confidence Interval (high)',
        // backgroundColor: '#eee',
        backgroundColor: 'rgba(230,230,230,0.5)',
        fill: 1,
        pointRadius: 0,
        lineTension: 0,
        borderColor: '#0000',
        borderWidth: 0,
        data: [] }]
    }
    this.lpiPlot = new Chart.Line(this.$refs.lpiplot.getContext('2d'), {
      data: that.lpiPlotDataSet,
      // Configuration options go here
      options: {
        responsive: true,
        legend: {
          display: false
        },
        maintainAspectRatio: false,
        scales: {
          yAxes: [{
            display: true,
            position: 'left',
            gridLines: {
              drawOnChartArea: true
            }
          }]
        }
      }
    })

    // -------intensity plot ----------------
    var baseLayer = L.tileLayer(
      '//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 5
      }
    )
    // TODO: might need to tweak some of these
    var cfg = {
      'fullscreenControl': true,
      'radius': 0.45,
      'maxOpacity': 0.8,
      'minOpacity': 0.5,
      'blur': 0.75,
      'scaleRadius': true,
      'useLocalExtrema': false,
      latField: 'lat',
      lngField: 'long',
      valueField: 'count',
      gradient: {0.25: 'rgb(0,94,255)', 0.5: 'rgb(0,0,255)', 0.85: 'rgb(163,0,255)', 1.0: 'rgb(255,0,255)'}
    }
    this.heatmapLayer = new HeatmapOverlay(cfg)
    this.map = new L.Map('intensityplot', {
      center: new L.LatLng(-25.917574, 132.702789),
      zoom: 3,
      layers: [baseLayer, this.heatmapLayer]
    })
    // /////////// map control /////////////////////////
    // setupbutton
    /*
    L.easyButton('<strong>&#9881;</strong>', function(buttonArg, mapArg) {
      // do stuff
      console.log('show settings')
    },
    { position: 'bottomleft' }).addTo(that.map)
*/
    L.easyButton({
      id: 'expand',
      position: 'bottomleft',
      states: [{
        icon: '<strong style="color: black">&swarr;</strong>',
        stateName: 'small',
        onClick: function(btn, map) {
          btn.state('big')
          that.showFullMap = true
          setTimeout(function() { window.dispatchEvent(new Event('resize')) })
        }
      }, {
        icon: '<strong style="color: black">&nearr;</strong>',
        stateName: 'big',
        onClick: function(btn, map) {
          btn.state('small')
          that.showFullMap = false
          setTimeout(function() { window.dispatchEvent(new Event('resize')) })
        }
      }]
    }).addTo(that.map)
    //
    // this is a hack so that leaflet displays properlly
    setTimeout(function() {
      that.map.invalidateSize()
      console.log('---update plot----')
    }, 2000)
    this.updatePlot()
  },
  watch: {
    selectedGroup(val) {
      this.subGroupList = subGroups.filter(x => val.value === 'None' || x.value === 'None' || x.group === val.value)
      if(this.selectedSubGroup && this.selectedSubGroup.group !== val.value) {
        this.selectedSubGroup = subGroups[0]
      }
      this.subGroupEnabled = this.subGroupList.length > 1
    },
    selectedStatusAuthority(val) {
      if(val.value === 'None') {
        this.selectedStatusDisabled = true
        this.selectedStatus = {value: 'None', text: 'All'}
      }
    },
    filterParams(val, oldVal) {
      this.queryLPIData = true
      this.loadingData = false
      this.updatePlot()
    },
    sliderRange(range) {
      if(!this.sliderEnabled || this.loadingMap) {
        return
      }
      var that = this
      var minYear = range[0]
      var maxYear = range[1]

      this.heatmapDataSet.data = Object.freeze(this.surveyData.filter(function(x) {
        return x.year >= minYear && x.year <= maxYear
      }))
      // var counts = this.heatmapDataSet.data.map(function(x) { return x.count })
      // this.heatmapDataSet.min = min(counts)
      // this.heatmapDataSet.max = max(counts)

      that.heatmapLayer.setData(that.heatmapDataSet)
    }
  },
  computed: {
    filterParams() {
      return this.getFilterParams()
    }
  },
  methods: {
    updatePlot: function() {
      console.log('Requery lpi data:' + this.queryLPIData)
      this.loadingData = true
      // clear existing data
      this.dotPlotDataSet.datasets[0].data = []
      this.dotPlotDataSet.datasets[1].data = []
      this.summaryPlotDataSet.datasets[0].data = []
      this.summaryPlotDataSet.datasets[1].data = []
      this.lpiPlotDataSet.labels = []
      this.lpiPlotDataSet.datasets[0].data = []
      this.lpiPlotDataSet.datasets[1].data = []
      this.lpiPlotDataSet.datasets[2].data = []
      this.heatmapDataSet.data = []
      this.surveyData = []
      // filters
      var filtersStr = this.getFilterString()
      var filterParams = this.getFilterParams()
      filterParams['format'] = 'plot'
      var that = this
      if(this.queryLPIData) {
        // ping api first
        api.lpiPlot(filterParams).then((data) => {
          this.noData = data['dotplot'].length === 0

          // console.log('Getting data')
          // console.log(data)
          // dotplot
          var dotPlotData = data['dotplot']

          dotPlotData.forEach(function(timeSeries, i) {
            timeSeries.forEach(function(value) {
              var year = value[0]
              var count = value[1]
              that.dotPlotDataSet.datasets[count === 0 ? 1 : 0].data.push({
                x: year,
                y: i + 1,
                r: 1
              })
            })
          })
          // summary plot
          // var speciesCountData = data['summary']['species']
          var taxaCountData = data['summary']['taxa']
          var timeSeriesCountData = data['summary']['timeseries']
          var year = 0
          for (year in taxaCountData) {
            that.summaryPlotDataSet.datasets[0].data.push({'x': +year, 'y': +taxaCountData[year]})
          }
          for (year in timeSeriesCountData) {
            that.summaryPlotDataSet.datasets[1].data.push({'x': +year, 'y': +timeSeriesCountData[year]})
          }
          that.dotPlot.update()
          // this will cause exception as the axis might be change
          // that.summaryPlot.update()
          that.refreshSummaryPlot()
        }).finally(() => {
          that.queryLPIData = false
          that.loadingData = false
        })
      }
      // intensity plot
      that.loadingMap = true
      this.sliderData.show = false

      // using lpi wide table per Elisa'request
      // filterParams.source = 'lpi_wide_table'

      api.intensityPlot(filterParams).then((data) => {
        if(data.length === 0) {
          return
        }

        console.log('--loading map data----')

        var surveyData = []
        data.forEach(function(timeSeries) {
          var lat = timeSeries[1]
          var long = timeSeries[0]
          var yearCounts = timeSeries[2]
          yearCounts.forEach(function(yearCount) {
            surveyData.push({
              lat: lat,
              long: long,
              count: yearCount[1],
              year: yearCount[0]
            })
          })
        })
        Object.freeze(surveyData) // Prevent Vue trying to observe survey data for changes
        that.surveyData = surveyData

        if(that.sliderEnabled) {
          var years = pluck(that.surveyData, 'year')
          that.sliderData.min = min(years)
          that.sliderData.max = max(years)
          that.sliderRange = [that.sliderData.min, that.sliderData.max]
        }

        var counts = pluck(that.surveyData, 'count')
        that.heatmapDataSet.max = max(counts)
        that.heatmapDataSet.min = min(counts)

        that.heatmapDataSet.data = that.surveyData
        that.heatmapLayer.setData(that.heatmapDataSet)
        // that.map.invalidateSize()
      }).finally(() => {
        that.loadingMap = false
        that.sliderData.show = that.sliderEnabled
      })
      // get files later
      api.lpiRunData(filtersStr, this.selectedYear.value, 'txt').then((data) => {
        if(data && data.indexOf('"LPI_final"') === 0) {
          // format:
          // "LPI_final" "CI_low" "CI_low"
          // "1980" float float float

          let plotData = that.lpiPlotDataSet

          let series = data.split('\n')
            .slice(1) // Ignore first line
            .filter(line => line.trim().length > 0 && !/NA/.test(line)) // Ignore empty or NA lines
            .map(line => line.split(' '))

          plotData.labels = series.map(x => parseInt(x[0].replace(/"/g, '')))
          plotData.datasets[0].data = series.map(x => parseFloat(x[1]))
          plotData.datasets[1].data = series.map(x => parseFloat(x[2]))
          plotData.datasets[2].data = series.map(x => parseFloat(x[3]))

          // update lpi plot
          that.noLPI = false
          that.lpiPlot.update()
        } else {
          that.noLPI = true
        }
      }).catch((e) => {
        console.log(e)
        that.noLPI = true
      }).finally(() => {
        if (!that.queryLPIData) {
          that.loadingData = false
        }
      })
    }, // end updatePlot function
    downloadCSV: function() {
      var filterParams = this.getFilterParams()
      filterParams['format'] = 'zip'
      filterParams['download'] = 'tsxdata.zip'
      var url = api.lpiDownloadURL(filterParams)
      window.open(url)
    },
    viewDataSummary: function() {
      var filterParams = this.getFilterParams()
      var url = api.lpiSummaryURL(filterParams)
      window.open(url)
    },
    acceptWarning: function() {
      localStorage.setItem('hasAcceptedWarning', true)
      this.hasAcceptedWarning = true
    },
    goBack: function() {
      window.history.back()
    },
    getFilterParams: function() {
      var filterParams = {}
      filterParams['reference_year'] = this.selectedYear.value
      if(this.prioritySelected) {
        filterParams['priority'] = 1
      } else {
        if(this.selectedGroup.value !== 'None') {
          filterParams['group'] = this.selectedGroup.value
        }
        if(this.selectedSubGroup.value !== 'None') {
          filterParams['subgroup'] = this.selectedSubGroup.value
        }
        if(this.selectedState.value !== 'None') {
          filterParams['state'] = this.selectedState.value
        }
        if(this.selectedStatusAuthority.value !== 'None') {
          filterParams['statusauth'] = this.selectedStatusAuthority.value
        }
        if(this.selectedStatus.value !== 'None') {
          filterParams['status'] = this.selectedStatus.value
        }
      }
      return filterParams
    },
    getFilterString: function() {
      var filtersStr = ''
      if(this.prioritySelected) {
        filtersStr = 'priority-1'
      } else {
        if(this.selectedGroup.value !== 'None') {
          filtersStr = filtersStr + 'group-' + this.selectedGroup.value + '_'
        }
        if(this.selectedSubGroup.value !== 'None') {
          filtersStr = filtersStr + 'subgroup-' + this.selectedSubGroup.value + '_'
        }
        if(this.selectedState.value !== 'None') {
          filtersStr = filtersStr + 'state-' + this.selectedState.value + '_'
        }
        if(this.selectedStatusAuthority.value !== 'None') {
          filtersStr = filtersStr + 'statusauth-' + this.selectedStatusAuthority.value + '_'
        }
        if(this.selectedStatus.value !== 'None') {
          filtersStr = filtersStr + 'status-' + this.selectedStatus.value + '_'
        }
      }
      return filtersStr
    },
    // refresh summary plot
    refreshSummaryPlot: function() {
      if (this.summaryPlot) {
        this.summaryPlot.destroy()
      }
      // create new one
      this.summaryPlot = new Chart.Scatter(this.$refs.sumplot.getContext('2d'), {
        data: this.summaryPlotDataSet,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          hoverMode: 'nearest',
          intersect: true,
          // title: {
          //   display: true,
          //   text: 'Data Summary'
          // },
          scales: {
            xAxes: [{
              position: 'bottom',
              gridLines: {
                zeroLineColor: 'rgba(0,0,0,1)'
              }
            }],
            yAxes: [{
              type: 'linear',
              display: true,
              position: 'left',
              scaleLabel: {
                display: true,
                labelString: 'Number of taxa'
              },
              id: 'y-axis-1',
              ticks: {
                // precision: 1 // Doesn't seem to work (contrary to documentation) so we use callback as a workaround
                callback: function(label, index, labels) {
                  return Math.floor(label) === label ? label : ''
                }
              }
            }, {
              type: 'linear',
              display: true,
              position: 'right',
              reverse: true,
              id: 'y-axis-2',
              scaleLabel: {
                display: true,
                labelString: 'Number of time series'
              },
              // grid line settings
              gridLines: {
                drawOnChartArea: false
              },
              ticks: {
                // See comment for other axis
                callback: function(label, index, labels) {
                  return Math.floor(label) === label ? label : ''
                }
              }
            }]
          }
        }
      })
    }
  }
}
</script>

<style src='leaflet/dist/leaflet.css'>
</style>
<style src='leaflet-easybutton/src/easy-button.css'>
</style>
<style scoped>
  h4 {
    /*margin-top: 0.5em;*/
    /*margin-left: 1em;*/
  }
  .heatmap-div {
    width: 100%;
    height: 25.5em;
    z-index:1;
  }
  .heatmap-spinner{
    z-index:2;
    position:absolute;
    top: 0.6em;
    right: 4em;
  }
  .heatmap-slider{
    z-index:2;
    width: 100%;
    height: 16px;
    position:absolute;
    top:0;
    bottom:0;
    left:0;
    right:0;
  }
  /* Important: the following line fixes the charts not resizing responsively */
  .tile {
    min-width: 0;
  }
  .tile.card {
    flex-basis: 22.5em;
    max-height: 22.5em;
    height: 22.5em;
    padding: 1em;
  }
  .plot-container {
    position: relative;
    height: 18em;
  }
  .tile.card.map-tile {
    padding: 0;
    padding-top: 1em;
  }
  .tile.card.map-tile h4 {
    margin-left: 1em;
  }

  .info-icon {
    color: #aaa;
    position: absolute;
    top: 0.7em;
    right: 1em;
    font-size: 120%;
  }
  .popup-content {
    max-width: 30em;
    text-align: left;
  }
  .popup-content p {
    margin-bottom: 1em;
  }
  .popup-content ol {
    padding-left: 1em;
  }
  .popup-content li {
    margin-bottom: 0.5em;
  }
  @media screen and (min-width: 768px) {
    .ie11-bugfix {
      /* Fix flexbox bug */
      height: 48em;
    }
  }
</style>
