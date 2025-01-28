using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Net.NetworkInformation;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Media.Animation;
using Microsoft.Win32;
using Microsoft.Win32.TaskScheduler;
using TaskScheduler;
using System.Threading.Tasks;

namespace PackageConsole
{
    public partial class Testing : Page
    {
        private CancellationTokenSource _loadingTextCts;
        public string DefaultDeviceName { get; set; } = Environment.MachineName; // Default to current machine name

        public Testing()
        {
            InitializeComponent();
            // Set the default mode to "Same Device" programmatically
            DeviceNameTextBox.Text = DefaultDeviceName;
            DeviceNameTextBox.IsEnabled = false;
            // Populate ComboBoxes with parameter options
            InstallParametersComboBox.ItemsSource = new string[] { "Install", "Install Silent", "MSI", "MSI+MST" };
            UninstallParametersComboBox.ItemsSource = new string[] { "Uninstall", "Uninstall Silent", "MSI", "MSI+MST" };

        }

        private void TestMode_Checked(object sender, RoutedEventArgs e)
        {
            if (DeviceNameTextBox == null)
            {
                // UI element is not initialized yet, exit early
                return;
            }

            if ((sender as RadioButton)?.Content.ToString() == "Same Device")
            {
                DeviceNameTextBox.Text = DefaultDeviceName;
                DeviceNameTextBox.IsEnabled = false;
            }
            else
            {
                DeviceNameTextBox.Text = string.Empty;
                DeviceNameTextBox.IsEnabled = true;
            }
        }

        // Event handler for Ping Device button
        private void PingDeviceButton_Click(object sender, RoutedEventArgs e)
        {
            string deviceName = DeviceNameTextBox.Text.Trim();

            if (string.IsNullOrWhiteSpace(deviceName))
            {
                StatusTextBlock.Text = "Status: Device name cannot be empty.";
                return;
            }

            bool isPingSuccessful = PingDevice(deviceName);

            if (isPingSuccessful)
            {
                StatusTextBlock.Text = $"Status: Ping to {deviceName} successful.";
            }
            else
            {
                StatusTextBlock.Text = $"Status: Ping to {deviceName} failed.";
            }
        }

        private bool PingDevice(string deviceName)
        {
            try
            {
                var ping = new System.Net.NetworkInformation.Ping();
                var reply = ping.Send(deviceName);
                return reply.Status == System.Net.NetworkInformation.IPStatus.Success;
            }
            catch
            {
                return false;
            }
        }

        // Event handler for Browse button
        private void BrowseFolderButton_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new Microsoft.Win32.OpenFileDialog
            {
                Title = "Select a folder",
                Filter = "Folders|*.", // Dummy filter to allow folder selection
                CheckFileExists = false, // Allow selection of non-existing paths
                FileName = "Select Folder"
            };

            if (dialog.ShowDialog() == true)
            {
                string selectedFolderPath = System.IO.Path.GetDirectoryName(dialog.FileName);
                if (!string.IsNullOrWhiteSpace(selectedFolderPath))
                {
                    PackageFolderTextBox.Text = selectedFolderPath;
                }
                else
                {
                    MessageBox.Show("Invalid folder selected.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        // Event handler for Run Install button
        private async void RunInstallButton_Click(object sender, RoutedEventArgs e)
        {
            string packageFolder = PackageFolderTextBox.Text.Trim();
            string installParameter = InstallParametersComboBox.SelectedItem?.ToString();

            if (string.IsNullOrWhiteSpace(packageFolder) || string.IsNullOrWhiteSpace(installParameter))
            {
                StatusTextBlock.Text = "Status: Please select an Install Parameter and Package Folder.";
                return;
            }

             RunTaskWithMonitoring("InstallTask", packageFolder, installParameter);
        }

        // Event handler for Run Uninstall button
        private async void RunUninstallButton_Click(object sender, RoutedEventArgs e)
        {
            string packageFolder = PackageFolderTextBox.Text.Trim();
            string uninstallParameter = UninstallParametersComboBox.SelectedItem?.ToString();

            if (string.IsNullOrWhiteSpace(packageFolder) || string.IsNullOrWhiteSpace(uninstallParameter))
            {
                StatusTextBlock.Text = "Status: Please select an Uninstall Parameter and Package Folder.";
                return;
            }

             RunTaskWithMonitoring("UninstallTask", packageFolder, uninstallParameter);
        }

        private async void RunTaskWithMonitoring(string taskName, string targetDir, string parameter)
        {
            try
            {
                if (!Directory.Exists(targetDir))
                {
                    StatusTextBlock.Text = "Status: Target directory does not exist.";
                    return;
                }

                string scriptContent = $@"
cd /d ""{targetDir}""
Deploy-Application.exe {parameter}";
                string scriptPath = Path.Combine(targetDir, $"{taskName}.cmd");
                File.WriteAllText(scriptPath, scriptContent);

                using (TaskService taskService = new TaskService())
                {
                    // Delete existing task if present
                    if (taskService.GetTask(taskName) != null)
                    {
                        taskService.RootFolder.DeleteTask(taskName);
                    }

                    // Start animations
                    StartLoadingAnimation();

                    // Create task
                    TaskDefinition taskDefinition = taskService.NewTask();
                    taskDefinition.RegistrationInfo.Description = $"Task for {taskName}";
                    taskDefinition.Triggers.Add(new TimeTrigger { StartBoundary = DateTime.Now.AddSeconds(5) });
                    taskDefinition.Actions.Add(new ExecAction("cmd.exe", $"/C \"{scriptPath}\"", targetDir));

                    taskService.RootFolder.RegisterTaskDefinition(taskName, taskDefinition);

                    MonitorTaskExecutionAsync(taskService, taskName);
                }
            }
            catch (Exception ex)
            {
                StatusTextBlock.Text = $"Status: Error occurred: {ex.Message}";
            }
            finally
            {
                StopLoadingAnimation();
            }
        }

        private async void MonitorTaskExecutionAsync(TaskService taskService, string taskName)
        {
            try
            {
                Microsoft.Win32.TaskScheduler.Task task = taskService.GetTask(taskName);

                if (task == null)
                {
                    StatusTextBlock.Text = $"Status: Task '{taskName}' not found.";
                    return;
                }

                while (true)
                {
                    task = taskService.GetTask(taskName); // Refresh task status

                    if (task.State == TaskState.Ready || task.State == TaskState.Queued)
                    {
                        StatusTextBlock.Text = $"Status: Task '{taskName}' completed successfully.";
                        break;
                    }

                    await System.Threading.Tasks.Task.Delay(2000);
                }
            }
            catch (Exception ex)
            {
                StatusTextBlock.Text = $"Status: Error while monitoring task: {ex.Message}";
            }
        }

        private void StartLoadingAnimation()
        {
            // Show progress bar
            StatusProgressBar.Visibility = Visibility.Visible;

            // Start spinner animation
            LoadingSpinner.Visibility = Visibility.Visible;
            Storyboard spinnerAnimation = (Storyboard)FindResource("SpinnerAnimation");
            spinnerAnimation.Begin();

            // Start status text animation
            _loadingTextCts = new CancellationTokenSource();
            CancellationToken token = _loadingTextCts.Token;

            System.Threading.Tasks.Task.Run(async () =>
            {
                string baseText = "Processing";
                int dotCount = 0;

                while (!token.IsCancellationRequested)
                {
                    Dispatcher.Invoke(() =>
                    {
                        StatusTextAnimated.Text = $"{baseText}{new string('.', dotCount % 4)}";
                        StatusTextAnimated.Visibility = Visibility.Visible;
                    });

                    dotCount++;
                    await System.Threading.Tasks.Task.Delay(500); // Update every 500ms
                }
            });
        }

        private void StopLoadingAnimation()
        {
            // Hide progress bar
            StatusProgressBar.Visibility = Visibility.Collapsed;

            // Stop spinner animation
            Storyboard spinnerAnimation = (Storyboard)FindResource("SpinnerAnimation");
            spinnerAnimation.Stop();
            LoadingSpinner.Visibility = Visibility.Collapsed;

            // Stop status text animation
            _loadingTextCts?.Cancel();
            StatusTextAnimated.Visibility = Visibility.Collapsed;
        }
    }
}
