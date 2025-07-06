# 使用するbucketの名前に変える
bucket         = "terraform-up-and-running-state-exercise" 
region         = "ap-northeast-1"
# 使用するtableの名前に変える
dynamodb_table = "terraform-up-and-running-locks"
encrypt        = true
# profileがあれば記載すること。なければ不要
# profile        = "exercise-user"