# International School TA Recruitment System

This is the software application developed by Group 15 for the BUPT International School Teaching Assistant Recruitment. The system is built using Jakarta EE (Java Servlet/JSP) with Agile methodologies, aiming to streamline the workflow for recruiting TAs.

## 👥 Collaborators (Group 15)
* **Student name:** Runtian Zhou  | **GitHub:** buptzrt | **QMID:** 231220013
* **Student name:** Sirong Qi     | **GitHub:** penguin-qsr | **QMID:** 231221157
* **Student name:** Chenyu Zhang  | **GitHub:** Charity-zcy | **QMID:** 231222062
* **Student name:** Jiayi Wang    | **GitHub:** lucy-wjy | **QMID:** 231220459
* **Student name:** Qiutong Chen  | **GitHub:** ChenQiutong-123 | **QMID:** 231222545
* **Student name:** Zichun Ao     | **GitHub:** aaazcshuaige0905 | **QMID:** 231222844
* **Support TA:** Yuxuan (yuxuanwwang@outlook.com)

---

## ⚙️ Environment Setup & Configuration Guide
This project is developed using pure Jakarta EE specifications. To successfully run the application in your local environment, please follow the setup instructions below:

### 🛠️ Dependencies
- **JDK Version**: Java 21 is highly recommended to avoid version conflicts (Ensure that both the `Project Structure` and `Java Compiler` syntax levels in IDEA are set to 21).
- **Build Tool**: Maven (Used to automatically download related dependencies, such as Gson, Jakarta Servlet API, etc.).
- **Web Server**: Tomcat 10.x or above.

### ⚠️ Core Configuration: Modifying JSON Data Source Paths
This project uses lightweight JSON files to simulate a local database, adhering to the "no database" requirement. After cloning the repository, **you MUST modify the hardcoded absolute paths in the backend DAO layer to match the actual paths on your local machine.**

Navigate to `src/main/java/com/me/finaldesignproject/dao` and open the DAO files responsible for data persistence (e.g., `JobDao.java`, `UserDao.java`). 
Find the `FILE_PATH` constant at the top of these files and change it to the absolute path of the relevant `.json` file on your computer, or replace the absolute path of the `resources` folder preceding `FILE_NAME` / `USER_JSON_FILE`.

* **Modification Example**:
  ```java
  // Please replace the path below with the actual path on your computer. Note: use forward slashes "/" for directory separators.
  private static final String FILE_PATH = "D:/TA-system/Group15_TA_SYSTEM-main-intermediate-assessment/TA_System/src/main/resources/jobs.json";
  ```
  Or replace the resources path preceding the FILE_NAME:
  ```java
  private static Path resolvePath() {
    // Using the resources directory as the storage location
    return Paths.get("D:/TA-system/Group15_TA_SYSTEM-main-intermediate-assessment/TA_System/src/main/resources/" + FILE_NAME);}
  ```

### 🚀 Deployment & Execution Steps

1. **Refresh Dependencies**: 
   Open the `Maven` panel on the right sidebar in IDEA, click the `Reload All Maven Projects` button, and wait for the underlying dependencies to finish downloading.

2. **Configure Tomcat**:
   * Click `Run` -> `Edit Configurations...` in the top menu bar of IDEA.
   * Click the `+` icon in the top left corner, select `Tomcat Server` -> `Local`.
   * Switch to the `Deployment` tab, click the `+` icon, select `Artifact`, and add the `Group15_TA_SYSTEM:war exploded` deployment package for this project.
   * *(Optional)* It is recommended to set the `Application context` to `/` to simplify the access path.

3. **Build and Start**:
   * Click `Build` -> `Rebuild Project` in the top menu bar to ensure a global error-free compilation.
   * Click the green `▶️ Run` or `🐛 Debug` button to start the Tomcat server. It will generally redirect to the login page directly.
   * Once successfully started, visit `http://localhost:8080/your_context_path/login.jsp` in your browser to access the system.

---

## 🚀 Implemented Features & System Roles

The system is divided into three core roles. The business functions currently implemented and integrated for each role are as follows:

### 👨‍🏫 MO (Module Organizer)

* **Account Basics**: Supports [Registration] and [Login].
* **Job Management**: Can [Create / Edit / Close / Reopen] their own new job requirements. Job information is instantly synchronized to the [Job Hall] for everyone to view.
* **Approval Workflow**:
    * Can receive applications from STUs.
    * Can view applicants' basic information and resume details.
    * Can perform approval actions on applications ([Approve] or [Reject]).

### 🎓 TA/STU (Student / TA Applicant)

* **Account Basics**: Supports [Registration] and [Login].
* **Resume Management**: Can [Create] and [Modify] personal online electronic resumes.
* **Job Application**:
    * Able to [Search] and [Filter] positions in the [Job Hall].
    * Can send job applications to the corresponding MO with one click.
* **Status Tracking**: Can instantly view the MO's processing status of their resume (Statuses include: `Approved`, `Rejected`, `Pending`).

### 🛡️ AD (Admin / System Administrator)

* **Account Basics**: Supports [Registration] and [Login].
* **Global Control**:
    * Can [Create new job requirements] and display them synchronously in the [Job Hall].
    * Has the highest administrative authority to forcefully [Close / Reopen / Delete] any anomalous jobs, with operation results synchronized in real-time to the TA/MO views.
* **Data Monitoring**: Can instantly view an overview of the status of all jobs across the site (Statuses include: `In Progress`, `Deadline Passed`, `Recruitment Completed`).
---


## 🔑 System Test Accounts

To facilitate feature experience and testing, the system has been pre-configured with the following test accounts.
> 💡 **Operation Tip**: When logging in, the account input box supports using EITHER **`EnrollmentNo (ID)`** OR **`Email`**.

| Role Type | EnrollmentNo (ID) | Email | Password |
| :--- | :--- | :--- | :--- |
| **STU (Student 1)** | `2023213099` | `zhangwei@bupt.edu.cn` | `123` |
| **STU (Student 2)** | `2023212133` | `lihao@bupt.edu.cn` | `123` |
| **MO (Teacher 1)** | `2018212121` | `jack@qq.com` | `123` |
| **MO (Teacher 2)** | `2019212121` | `tom@qq.com` | `123` |
| **AD (Admin)** | `2020212121` | `dao@bupt.edu.cn` | `123` |

---
