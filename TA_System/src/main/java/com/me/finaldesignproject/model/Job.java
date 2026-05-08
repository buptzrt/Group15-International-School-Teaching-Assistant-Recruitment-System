

/**
 * Model class representing a Teaching Assistant job posting created by a Module Organizer (MO)/admin.
 *
 * 该类不仅包含岗位基础信息，还包含发布、审批、修改、删除、学生申请统计等功能所需字段。
 */
package com.me.finaldesignproject.model;

import java.io.Serializable;

public class Job implements Serializable {

    private static final long serialVersionUID = 1L;

    // 基本信息
    private String jobId;
    private String creatorId;
    private String creatorRole;

    // 核心信息
    private String courseName;
    private String moduleCode;
    private String jobTitle;
    private int numberOfPositions;
    private String applicationDeadline;

    // 详细描述
    private String requiredSkills;
    private String jobResponsibilities;
    private String workingHours;
    private String location;
    private String activityType;
    private String semester;
    private double cgpaRequired;
    private String preferredMajor;

    // 联系方式
    private String contactEmail;
    private String contactPhone;

    // 状态
    private String status;
    private String postedDate;
    private String lastUpdatedDate;
    private String lastModifiedBy;
    private String lastModifiedRole;
    private boolean deleted;

    // 招募情况
    private int applicationsReceived;
    private int applicationsAccepted;

    // 权限控制
    private boolean studentCanApply;
    private boolean editable;
    private boolean deletable;
    private String approvalStatus;

    private String creatorName; // 新增字段

    // 在 Job.java 中增加
    private int aiScore = 0; // 匹配度分数
    private String aiReason = ""; // 匹配理由

    // 无参构造
    public Job() {}

    // 全参构造（已严格匹配字段）
    public Job(String jobId, String creatorId, String creatorRole,
               String courseName, String moduleCode, String jobTitle,
               int numberOfPositions, String applicationDeadline,
               String requiredSkills, String jobResponsibilities, String workingHours,
               String location, String activityType, String semester,
               double cgpaRequired, String preferredMajor,
               String contactEmail, String contactPhone,
               String status, String postedDate, String lastUpdatedDate,
               String lastModifiedBy, String lastModifiedRole,
               boolean deleted, int applicationsReceived, int applicationsAccepted,
               boolean studentCanApply, boolean editable, boolean deletable,
               String approvalStatus) {

        this.jobId = jobId;
        this.creatorId = creatorId;
        this.creatorRole = creatorRole;
        this.courseName = courseName;
        this.moduleCode = moduleCode;
        this.jobTitle = jobTitle;
        this.numberOfPositions = numberOfPositions;
        this.applicationDeadline = applicationDeadline;

        this.requiredSkills = requiredSkills;
        this.jobResponsibilities = jobResponsibilities;
        this.workingHours = workingHours;
        this.location = location;
        this.activityType = activityType;
        this.semester = semester;
        this.cgpaRequired = cgpaRequired;
        this.preferredMajor = preferredMajor;

        this.contactEmail = contactEmail;
        this.contactPhone = contactPhone;

        this.status = status;
        this.postedDate = postedDate;
        this.lastUpdatedDate = lastUpdatedDate;
        this.lastModifiedBy = lastModifiedBy;
        this.lastModifiedRole = lastModifiedRole;
        this.deleted = deleted;

        this.applicationsReceived = applicationsReceived;
        this.applicationsAccepted = applicationsAccepted;

        this.studentCanApply = studentCanApply;
        this.editable = editable;
        this.deletable = deletable;
        this.approvalStatus = approvalStatus;
    }

    // Getter & Setter

    public String getJobId() { return jobId; }
    public void setJobId(String jobId) { this.jobId = jobId; }

    public String getCreatorId() { return creatorId; }
    public void setCreatorId(String creatorId) { this.creatorId = creatorId; }

    public String getCreatorRole() { return creatorRole; }
    public void setCreatorRole(String creatorRole) { this.creatorRole = creatorRole; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getModuleCode() { return moduleCode; }
    public void setModuleCode(String moduleCode) { this.moduleCode = moduleCode; }

    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }

    public int getNumberOfPositions() { return numberOfPositions; }
    public void setNumberOfPositions(int numberOfPositions) { this.numberOfPositions = numberOfPositions; }

    public String getApplicationDeadline() { return applicationDeadline; }
    public void setApplicationDeadline(String applicationDeadline) { this.applicationDeadline = applicationDeadline; }

    public String getRequiredSkills() { return requiredSkills; }
    public void setRequiredSkills(String requiredSkills) { this.requiredSkills = requiredSkills; }

    public String getJobResponsibilities() { return jobResponsibilities; }
    public void setJobResponsibilities(String jobResponsibilities) { this.jobResponsibilities = jobResponsibilities; }

    public String getWorkingHours() { return workingHours; }
    public void setWorkingHours(String workingHours) { this.workingHours = workingHours; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getActivityType() { return activityType; }
    public void setActivityType(String activityType) { this.activityType = activityType; }

    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }

    public double getCgpaRequired() { return cgpaRequired; }
    public void setCgpaRequired(double cgpaRequired) { this.cgpaRequired = cgpaRequired; }

    public String getPreferredMajor() { return preferredMajor; }
    public void setPreferredMajor(String preferredMajor) { this.preferredMajor = preferredMajor; }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPostedDate() { return postedDate; }
    public void setPostedDate(String postedDate) { this.postedDate = postedDate; }

    public String getLastUpdatedDate() { return lastUpdatedDate; }
    public void setLastUpdatedDate(String lastUpdatedDate) { this.lastUpdatedDate = lastUpdatedDate; }

    public String getLastModifiedBy() { return lastModifiedBy; }
    public void setLastModifiedBy(String lastModifiedBy) { this.lastModifiedBy = lastModifiedBy; }

    public String getLastModifiedRole() { return lastModifiedRole; }
    public void setLastModifiedRole(String lastModifiedRole) { this.lastModifiedRole = lastModifiedRole; }

    public boolean isDeleted() { return deleted; }
    public void setDeleted(boolean deleted) { this.deleted = deleted; }

    public int getApplicationsReceived() { return applicationsReceived; }
    public void setApplicationsReceived(int applicationsReceived) { this.applicationsReceived = applicationsReceived; }

    public int getApplicationsAccepted() { return applicationsAccepted; }
    public void setApplicationsAccepted(int applicationsAccepted) { this.applicationsAccepted = applicationsAccepted; }

    public boolean isStudentCanApply() { return studentCanApply; }
    public void setStudentCanApply(boolean studentCanApply) { this.studentCanApply = studentCanApply; }

    public boolean isEditable() { return editable; }
    public void setEditable(boolean editable) { this.editable = editable; }

    public boolean isDeletable() { return deletable; }
    public void setDeletable(boolean deletable) { this.deletable = deletable; }

    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }

    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }

    // 对应的 Getter 和 Setter
    public int getAiScore() { return aiScore; }
    public void setAiScore(int aiScore) { this.aiScore = aiScore; }
    public String getAiReason() { return aiReason; }
    public void setAiReason(String aiReason) { this.aiReason = aiReason; }

    @Override
    public String toString() {
        return "Job{" +
                "jobId='" + jobId + '\'' +
                ", courseName='" + courseName + '\'' +
                ", jobTitle='" + jobTitle + '\'' +
                ", status='" + status + '\'' +
                ", approvalStatus='" + approvalStatus + '\'' +
                '}';
    }
}
