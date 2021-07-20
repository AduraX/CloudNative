﻿$resourceGroupName = "12345ps"$storageAccountName = "s$resourceGroupName"$containerName = "hdp$resourceGroupName"$clusterName = $containerName$httpUserName = "hduser"$password = ConvertTo-SecureString "MyPa`$`$w0rd" -AsPlainText -Force$credential = New-Object System.Management.Automation.PSCredential ($httpUserName, $password)# Upload source data$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName | %{ $_[0].Value }$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKeySet-AzureStorageBlobContent -File c:\files\treasure-island.txt -Context $blobContext -Container $containerName -Blob data/treasure-island.txt -Force# Run a Map/Reduce job$jobDef = New-AzureRmHDInsightMapReduceJobDefinition -JarFile "/example/jars/hadoop-mapreduce-examples.jar" -ClassName "wordcount" -Arguments "/data/treasure-island.txt", "/data/output" -StatusFolder "status"$wordCountJob = Start-AzureRmHDInsightJob –ClusterName $clusterName –JobDefinition $jobDef -ResourceGroupName $resourceGroupName -HttpCredential $credentialWrite-Host "Map/Reduce job submitted..." # Wait, and then display job output informationWait-AzureRmHDInsightJob -JobId $wordCountJob.JobId -ResourceGroupName $resourceGroupName -ClusterName $clusterName -HttpCredential $credentialGet-AzureRmHDInsightJobOutput -ClusterName $clusterName -JobId $wordCountJob.JobId -ResourceGroupName $resourceGroupName -HttpCredential $credential -DefaultStorageAccountName $storageAccountName -DefaultContainer $containerName -DefaultStorageAccountKey $storageAccountKey# Download output fileWrite-Host "Downloading results..."Get-AzureStorageBlobContent -Context $blobContext -Container $containerName -Blob data/output/part-r-00000 -Destination "C:\files"dir c:\files\data\output\part-r-00000