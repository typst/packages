#import "@preview/culsc-record:0.11.0": *
//#import "/lib.typ": *

#show: culsc-record.with(
  // text-fontset: "windows",
  // math-fontset: "windows",
  session: "十一",
  serial: "",      // 序号
  start-year: "",  // 开始年
  start-month: "", // 开始月
  start-day: "",   // 开始日
  start-time: "",  // 开始时间
  end-year: "",    // 结束年
  end-month: "",   // 结束月
  end-day: "",     // 结束日
  end-time: ""     // 结束时间
)

// 开始撰写实际内容
#noindent[
*注意：*

1、“序号”是实验记录的顺序，1、2、3等，不是团队编号。

2、所有上传材料中请勿出现团队编号、任何学校名称和姓名。

3、避免出现明确的实验材料采样和保存地点，比如xx菌种保存在xx学校菌种库，xx材料从xx学校采集获得。

4、避免出现过多的实验过程照片，比如穿着xx学校实验服的学生，贴有xx学校固定资产的实验仪器，有xx学校抬头的实验记录纸。

5、避免出现团队成员合照、正面照片、指导老师照片。

6、参考文献中的姓名学校没有关系。

7、实验记录内容没有格式要求。

（撰写实验记录时请删除这段话）
]

// 打印参考文献
// #print-bib(bibliography: bibliography.with("ref-02.bib"),)