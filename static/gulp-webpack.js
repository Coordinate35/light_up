//var webpack = require('webpack');
//var commonsPlugin = new webpack.optimize.CommonsChunkPlugin('common.js');

module.exports = {
	//插件项
//	plugins: [commonsPlugin],
	//页面入口文件配置
	entry: {
		index : [
			'./scripts/src/index.js'
		],
		presonal: [
			'./scripts/src/personal.js'
		],
		others: [
			'./scripts/src/others.js'
		]
	},
	//入口文件输出配置
	output: {
		//path:'./scripts/dist/',
		filename: '[name].js'
	},
	module: {
		//加载器配置
		loaders: [{
			test: /\.tpl$/,
			loader: 'tmodjs-loader'
		},{
			test: /\.css$/,
			loader: 'style-loader!css-loader'
		}, {
			test: /\.scss$/,
			loader: 'style!css!sass?sourceMap'
		}, {
			test: /\.(png|jpg)$/,
			loader: 'url-loader?limit=8192'
		}]
	},
	//其它解决方案配置
	resolve: {
		extensions: ['', '.js', '.json', '.scss'],
	}
};