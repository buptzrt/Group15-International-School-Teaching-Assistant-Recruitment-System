package com.me.finaldesignproject.model;

import java.io.Serializable;

/**
 * Model class representing a Teaching Assistant job posting created by a Module Organizer (MO)/admin.
 *
 * 该类不仅包含岗位基础信息，还包含发布、审批、修改、删除、学生申请统计等功能所需字段。
 */
public class Job implements Serializable {

    private static final long serialVersionUID = 1L;

    // 唯一岗位编号，对应数据库表中的主键。
    private int jobId;

    // 创建该岗位的发布者 ID（例如 MO 或管理员账号 ID）。
    private int creatorId;

    // 创建者身份，例如 "MO"、"Admin"。
    private String creatorRole;

    // 课程名称/模块名称，用于描述该助教岗位对应的课程。
    private String courseName;

    // 岗位标题，例如 "数据结构助教"、"实验辅导助教"。
    private String jobTitle;

    // 岗位详细描述，包含职责、要求、工作内容说明等。
    private String jobDescription;

    // 课程编码或部门名称，便于管理和筛选。
    private String moduleCode;

    // 学期信息，例如 "2026春季"、"2026秋季"。
    private String semester;

    // 学生申请截止日期。
    private String applicationDeadline;

    // 招聘名额数量。
    private int numberOfPositions;

    // 当前已收到的申请数量。
    private int applicationsReceived;

    // 已通过或已录取的申请人数。
    private int applicationsAccepted;

    // 最低 CGPA 要求。
    private double cgpaRequired;

    // 学生优先专业要求，例如 "计算机科学"、"电子信息"。
    private String preferredMajor;

    // 助教岗位类型，例如 "课程辅导"、"实验指导"、"答疑"。
    private String jobCategory;

    // 工作模式或地点，例如 "线上"、"线下"、"混合"。
    private String location;

    // 联系邮箱，用于接收咨询。
    private String contactEmail;

    // 联系电话，用于紧急联系或补充说明。
    private String contactPhone;

    // 岗位当前状态，例如 "Open"、"Closed"、"Filled"、"Deleted"。
    private String status;

    // 后端判断该岗位是否对学生开放申请（true = 可以申请）。
    private boolean studentCanApply;

    // 是否处于可编辑状态（管理员或 MO 可以修改）。
    private boolean editable;

    // 是否允许管理员删除该岗位。
    private boolean deletable;

    // 审批状态，例如 "Pending"、"Approved"、"Rejected"。
    private String approvalStatus;

    // 岗位发布时间。
    private String postedDate;

    // 最后更新时间。
    private String lastUpdatedDate;

    // 最后修改该岗位的用户 ID。
    private int lastModifiedBy;

    // 最后修改该岗位的用户角色。
    private String lastModifiedRole;

    // 逻辑删除标记，true 表示该岗位已删除但仍保留在系统中。
    private boolean deleted;

    public Job() {
        // Default constructor for bean usage and serialization.
    }

    public Job(int jobId, int creatorId, String creatorRole, String courseName, String jobTitle,
               String jobDescription, String moduleCode, String semester, String applicationDeadline,
               int numberOfPositions, int applicationsReceived, int applicationsAccepted,
               double cgpaRequired, String preferredMajor, String jobCategory, String location,
               String contactEmail, String contactPhone, String status, boolean studentCanApply,
               boolean editable, boolean deletable, String approvalStatus, String postedDate,
               String lastUpdatedDate, int lastModifiedBy, String lastModifiedRole, boolean deleted) {
        this.jobId = jobId;
        this.creatorId = creatorId;
        this.creatorRole = creatorRole;
        this.courseName = courseName;
        this.jobTitle = jobTitle;
        this.jobDescription = jobDescription;
        this.moduleCode = moduleCode;
        this.semester = semester;
        this.applicationDeadline = applicationDeadline;
        this.numberOfPositions = numberOfPositions;
        this.applicationsReceived = applicationsReceived;
        this.applicationsAccepted = applicationsAccepted;
        this.cgpaRequired = cgpaRequired;
        this.preferredMajor = preferredMajor;
        this.jobCategory = jobCategory;
        this.location = location;
        this.contactEmail = contactEmail;
        this.contactPhone = contactPhone;
        this.status = status;
        this.studentCanApply = studentCanApply;
        this.editable = editable;
        this.deletable = deletable;
        this.approvalStatus = approvalStatus;
        this.postedDate = postedDate;
        this.lastUpdatedDate = lastUpdatedDate;
        this.lastModifiedBy = lastModifiedBy;
        this.lastModifiedRole = lastModifiedRole;
        this.deleted = deleted;
    }

    public int getJobId() {
        return jobId;
    }

    public void setJobId(int jobId) {
        this.jobId = jobId;
    }

    public int getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(int creatorId) {
        this.creatorId = creatorId;
    }

    public String getCreatorRole() {
        return creatorRole;
    }

    public void setCreatorRole(String creatorRole) {
        this.creatorRole = creatorRole;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }

    public String getJobDescription() {
        return jobDescription;
    }

    public void setJobDescription(String jobDescription) {
        this.jobDescription = jobDescription;
    }

    public String getModuleCode() {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode) {
        this.moduleCode = moduleCode;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public String getApplicationDeadline() {
        return applicationDeadline;
    }

    public void setApplicationDeadline(String applicationDeadline) {
        this.applicationDeadline = applicationDeadline;
    }

    public int getNumberOfPositions() {
        return numberOfPositions;
    }

    public void setNumberOfPositions(int numberOfPositions) {
        this.numberOfPositions = numberOfPositions;
    }

    public int getApplicationsReceived() {
        return applicationsReceived;
    }

    public void setApplicationsReceived(int applicationsReceived) {
        this.applicationsReceived = applicationsReceived;
    }

    public int getApplicationsAccepted() {
        return applicationsAccepted;
    }

    public void setApplicationsAccepted(int applicationsAccepted) {
        this.applicationsAccepted = applicationsAccepted;
    }

    public double getCgpaRequired() {
        return cgpaRequired;
    }

    public void setCgpaRequired(double cgpaRequired) {
        this.cgpaRequired = cgpaRequired;
    }

    public String getPreferredMajor() {
        return preferredMajor;
    }

    public void setPreferredMajor(String preferredMajor) {
        this.preferredMajor = preferredMajor;
    }

    public String getJobCategory() {
        return jobCategory;
    }

    public void setJobCategory(String jobCategory) {
        this.jobCategory = jobCategory;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isStudentCanApply() {
        return studentCanApply;
    }

    public void setStudentCanApply(boolean studentCanApply) {
        this.studentCanApply = studentCanApply;
    }

    public boolean isEditable() {
        return editable;
    }

    public void setEditable(boolean editable) {
        this.editable = editable;
    }

    public boolean isDeletable() {
        return deletable;
    }

    public void setDeletable(boolean deletable) {
        this.deletable = deletable;
    }

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public String getPostedDate() {
        return postedDate;
    }

    public void setPostedDate(String postedDate) {
        this.postedDate = postedDate;
    }

    public String getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(String lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }

    public int getLastModifiedBy() {
        return lastModifiedBy;
    }

    public void setLastModifiedBy(int lastModifiedBy) {
        this.lastModifiedBy = lastModifiedBy;
    }

    public String getLastModifiedRole() {
        return lastModifiedRole;
    }

    public void setLastModifiedRole(String lastModifiedRole) {
        this.lastModifiedRole = lastModifiedRole;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    @Override
    public String toString() {
        return "Job{" +
                "jobId=" + jobId +
                ", creatorId=" + creatorId +
                ", creatorRole='" + creatorRole + '\'' +
                ", courseName='" + courseName + '\'' +
                ", jobTitle='" + jobTitle + '\'' +
                ", applicationDeadline='" + applicationDeadline + '\'' +
                ", numberOfPositions=" + numberOfPositions +
                ", applicationsReceived=" + applicationsReceived +
                ", applicationsAccepted=" + applicationsAccepted +
                ", cgpaRequired=" + cgpaRequired +
                ", status='" + status + '\'' +
                ", studentCanApply=" + studentCanApply +
                ", editable=" + editable +
                ", deletable=" + deletable +
                ", approvalStatus='" + approvalStatus + '\'' +
                ", deleted=" + deleted +
                '}';
    }
}
