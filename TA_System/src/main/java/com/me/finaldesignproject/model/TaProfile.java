package com.me.finaldesignproject.model;

/**
 * TA 个人资料（与登录用户学号 enrollmentNo 关联）
 */
public class TaProfile {

    private String enrollmentNo;
    private String fullName;
    private String studentId;
    private String chineseName;
    private String gender;
    private String qmId;
    private String buptId;
    private String buptClass;
    private String majorProgramme;
    private String grade;
    private String email;
    private String mobilePhone;
    private String wechatId;
    private String priorProgramme; // yes/no details
    private String priorAnswer;    // "Yes"/"No"
    private String availability;   // All semester / others
    private String availabilityNotes;
    private String campusPreference; // BUPT main / Shahe / Both
    private String skills; // comma separated skills selection
    private String resumePath;

    public TaProfile() {
    }

    public String getEnrollmentNo() {
        return enrollmentNo;
    }

    public void setEnrollmentNo(String enrollmentNo) {
        this.enrollmentNo = enrollmentNo;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getChineseName() { return chineseName; }
    public void setChineseName(String chineseName) { this.chineseName = chineseName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getQmId() { return qmId; }
    public void setQmId(String qmId) { this.qmId = qmId; }

    public String getBuptId() { return buptId; }
    public void setBuptId(String buptId) { this.buptId = buptId; }

    public String getBuptClass() { return buptClass; }
    public void setBuptClass(String buptClass) { this.buptClass = buptClass; }

    public String getMajorProgramme() { return majorProgramme; }
    public void setMajorProgramme(String majorProgramme) { this.majorProgramme = majorProgramme; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMobilePhone() { return mobilePhone; }
    public void setMobilePhone(String mobilePhone) { this.mobilePhone = mobilePhone; }

    public String getWechatId() { return wechatId; }
    public void setWechatId(String wechatId) { this.wechatId = wechatId; }

    public String getPriorProgramme() { return priorProgramme; }
    public void setPriorProgramme(String priorProgramme) { this.priorProgramme = priorProgramme; }

    public String getPriorAnswer() { return priorAnswer; }
    public void setPriorAnswer(String priorAnswer) { this.priorAnswer = priorAnswer; }

    public String getAvailability() { return availability; }
    public void setAvailability(String availability) { this.availability = availability; }

    public String getAvailabilityNotes() { return availabilityNotes; }
    public void setAvailabilityNotes(String availabilityNotes) { this.availabilityNotes = availabilityNotes; }

    public String getCampusPreference() { return campusPreference; }
    public void setCampusPreference(String campusPreference) { this.campusPreference = campusPreference; }

    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }

    public String getResumePath() {
        return resumePath;
    }

    public void setResumePath(String resumePath) {
        this.resumePath = resumePath;
    }
}
