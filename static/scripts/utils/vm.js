function VM(opt){
	var data = opt.data
	var newObj = {
		data:{}
	};
	for(key in data){
		(function(key){
			newObj.data[key] = data[key].value;
			Object.defineProperty(newObj.data,key,{
				get:function(){
					return data[key].value;
				},
				set:function(value){
					data[key].value = value;
					if(data[key].$el){
						var type = data[key].type;
						if(type == 'text'){
							data[key].$el.text(data[key].value);
						}
						else {
							data[key].$el.attr(type,data[key].value);
						}
					}
				}
			})
		})(key)
	}
	return newObj;
}


module.exports = VM