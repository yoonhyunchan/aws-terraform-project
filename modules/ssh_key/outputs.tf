output ssh_key_name {
    description = "SSH KEY NAME"
    value = aws_key_pair.generated.key_name
}