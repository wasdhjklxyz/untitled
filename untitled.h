#ifndef _UNTITLED_H
#define _UNTITLED_H

#include <linux/types.h>
#include <linux/fs.h>
#include <linux/compiler_types.h>
#include <linux/semaphore.h>
#include <linux/cdev.h>

struct cdev *untitled_cdev;

struct untitled_dev {
	struct untitled_qset *data;
	int quantum;
	int qset;
	unsigned long size;
	unsigned int access_key;
	struct semaphore sem;
	struct cdev cdev;
};

ssize_t untitled_read(struct file *filp, char __user *buf, size_t count,
		      loff_t *pos);
ssize_t untitled_write(struct file *filp, const char __user *buf, size_t count,
		       loff_t *pos);
int untitled_open(struct inode *inode, struct file *filp);
int untitled_release(struct inode *inode, struct file *filp);

#endif
