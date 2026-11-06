import * as echarts from 'echarts';

function render(width, height, options) {
    let chart = echarts.init(null, null, {
        renderer: 'svg',
        ssr: true,
        width: width,
        height: height,
    });
    chart.setOption(Object.assign({}, options, { animation: false }));
    const svg = chart.renderToSVGString();
    chart.dispose();
    return svg;
}

export { render }; 