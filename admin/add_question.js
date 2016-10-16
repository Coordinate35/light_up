question_class = "value_concept";
question = {
	"question_content": "Have you sex",
	"available": true,
}
question['time'] = +(new Date());
question['time'] = Math.floor(question['time'] / 1000);
db[question_class].insert(question);
