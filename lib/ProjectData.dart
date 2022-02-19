class ProjectData {
  String projectname;
  String svgurl;
  String starthour;
  String startmin;
  String endhour;
  String endmin;
  bool status;
  String day;
  String time;

  ProjectData({this.projectname, this.svgurl,this.starthour,this.startmin,this.endhour,this.endmin,this.status,this.day,this.time});

  ProjectData.fromJson(Map<String, dynamic> json) {
    projectname = json['projectname'];
    svgurl = json['svgurl'];
    starthour = json['starthour'];
    startmin = json['startmin'];
    endhour = json['endhour'];
    endmin = json['endmin'];
    status = json['status'];
    day = json['day'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectname'] = this.projectname;
    data['svgurl'] = this.svgurl;
    data['starthour'] = this.starthour;
    data['startmin'] = this.startmin;
    data['endhour'] = this.endhour;
    data['endmin'] = this.endmin;
    data['status'] = this.status;
    data['day'] = this.day;
    data['time'] = this.time;
    return data;
  }
}