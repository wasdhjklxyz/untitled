#include <linux/fs.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/cdev.h>

#include "untitled.h"

MODULE_LICENSE("GPL-2.0");

dev_t dev;
int nr_devs = 4;

static const struct file_operations fops = {
	.owner = THIS_MODULE,
	.llseek = generic_file_llseek,
	.read = untitled_read,
	.write = untitled_write,
	.open = untitled_open,
	.release = untitled_release,
};

ssize_t untitled_read(struct file *filp, char __user *buf, size_t count,
		      loff_t *pos)
{
	printk(KERN_DEBUG "untitled: read");
	return 0;
}

ssize_t untitled_write(struct file *filp, const char __user *buf, size_t count,
		       loff_t *pos)
{
	printk(KERN_DEBUG "untitled: write");
	return 0;
}

int untitled_open(struct inode *inode, struct file *filp)
{
	printk(KERN_DEBUG "untitled: open");
	return 0;
}

int untitled_release(struct inode *inode, struct file *filp)
{
	printk(KERN_DEBUG "untitled: release");
	return 0;
}

static int hello_init(void)
{
	printk(KERN_ALERT "hello world\n");

	int ret = alloc_chrdev_region(&dev, MINOR(dev), nr_devs, "untitled");
	if (ret < 0) {
		printk(KERN_ERR "Error: alloc_chrdev_region\n");
		return ret;
	}

	struct cdev *untitled_cdev = cdev_alloc();
	if (!untitled_cdev) {
		printk(KERN_ERR "Error: cdev_alloc\n");
		return 1;
	}

	cdev_init(untitled_cdev, &fops);
	untitled_cdev->owner = THIS_MODULE;

	// TODO: Wait for device files to be created before adding?
	ret = cdev_add(untitled_cdev, MINOR(dev), 1);
	if (ret < 0) {
		printk(KERN_ERR "Error: cdev_add\n");
		return ret;
	}

	return 0;
}

static void hello_exit(void)
{
	// TODO: cdev_del(untitled_cdev);

	unregister_chrdev_region(dev, nr_devs);

	printk(KERN_ALERT "goodbye\n");
}

module_init(hello_init);
module_exit(hello_exit);
