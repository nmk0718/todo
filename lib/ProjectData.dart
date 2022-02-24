class ProjectData {
  String projectname;
  String svgurl;
  String starttime;
  String endtime;
  bool status;
  String dakatime;

  ProjectData({this.projectname, this.svgurl,this.starttime,this.endtime,this.status,this.dakatime});

  ProjectData.fromJson(Map<String, dynamic> json) {
    projectname = json['projectname'];
    svgurl = json['svgurl'];
    starttime = json['starttime'];
    endtime = json['endtime'];
    status = json['status'];
    dakatime = json['dakatime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectname'] = this.projectname;
    data['svgurl'] = this.svgurl;
    data['starttime'] = this.starttime;
    data['endtime'] = this.endtime;
    data['status'] = this.status;
    data['dakatime'] = this.dakatime;
    return data;
  }
}