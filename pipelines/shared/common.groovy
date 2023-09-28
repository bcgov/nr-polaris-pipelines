// Helper Functions
def getCauseUserId() {
    def userIdCause = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause');
    final String nameFromUserIdCause = userIdCause != null && userIdCause[0] != null ? userIdCause[0].userId : null;
    if (nameFromUserIdCause != null) {
        return nameFromUserIdCause + "@azureidir";
    } else {
        return 'unknown'
    }
}

def convertLongEnvToShort(env) {
    envLongToShort = [:]
    envLongToShort["production"] = "prod"
    envLongToShort["test"] = "test"
    envLongToShort["development"] = "dev"
    return envLongToShort[env]
}

return this
